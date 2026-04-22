const csrfToken = () => document.querySelector("meta[name='csrf-token']")?.content

const encodeBase64Url = (buffer) => {
  const bytes = new Uint8Array(buffer)
  let value = ""

  bytes.forEach((byte) => {
    value += String.fromCharCode(byte)
  })

  return btoa(value).replace(/\+/g, "-").replace(/\//g, "_").replace(/=+$/g, "")
}

const decodeBase64Url = (value) => {
  const base64 = value.replace(/-/g, "+").replace(/_/g, "/")
  const padded = base64.padEnd(Math.ceil(base64.length / 4) * 4, "=")
  const binary = atob(padded)
  const bytes = new Uint8Array(binary.length)

  for (let index = 0; index < binary.length; index += 1) {
    bytes[index] = binary.charCodeAt(index)
  }

  return bytes.buffer
}

const jsonFetch = async (url, body) => {
  const response = await fetch(url, {
    method: "POST",
    credentials: "same-origin",
    headers: {
      "Content-Type": "application/json",
      "Accept": "application/json",
      "X-CSRF-Token": csrfToken()
    },
    body: JSON.stringify(body || {})
  })

  const payload = await response.json().catch(() => ({}))

  if (!response.ok) {
    throw new Error(payload.error || "Nao foi possivel concluir a autenticacao.")
  }

  return payload
}

const prepareCreateOptions = (options) => {
  options.challenge = decodeBase64Url(options.challenge)
  options.user.id = decodeBase64Url(options.user.id)
  options.excludeCredentials = (options.excludeCredentials || []).map((credential) => ({
    ...credential,
    id: decodeBase64Url(credential.id)
  }))
  return options
}

const prepareGetOptions = (options) => {
  options.challenge = decodeBase64Url(options.challenge)
  options.allowCredentials = (options.allowCredentials || []).map((credential) => ({
    ...credential,
    id: decodeBase64Url(credential.id)
  }))
  return options
}

const credentialToJson = (credential) => {
  const response = credential.response
  const payload = {
    id: credential.id,
    type: credential.type,
    rawId: encodeBase64Url(credential.rawId),
    clientExtensionResults: credential.getClientExtensionResults(),
    response: {
      clientDataJSON: encodeBase64Url(response.clientDataJSON)
    }
  }

  if (response.attestationObject) {
    payload.response.attestationObject = encodeBase64Url(response.attestationObject)
  }

  if (response.authenticatorData) {
    payload.response.authenticatorData = encodeBase64Url(response.authenticatorData)
    payload.response.signature = encodeBase64Url(response.signature)
    payload.response.userHandle = response.userHandle ? encodeBase64Url(response.userHandle) : null
  }

  if (response.getTransports) {
    payload.response.transports = response.getTransports()
  }

  return payload
}

const setAuthStatus = (root, selector, message, variant = "secondary") => {
  const status = root.querySelector(selector)
  if (!status) return

  status.className = `alert alert-${variant} mb-0`
  status.textContent = message
}

const withPasskeyCeremony = async (callback) => {
  window.financialManagerPasskeyBusy = true

  try {
    return await callback()
  } finally {
    window.financialManagerPasskeyBusy = false
  }
}

const registerAccountPasskey = async (root) => {
  if (!window.PublicKeyCredential) {
    setAuthStatus(root, "[data-passkey-setup-status]", "Este navegador nao suporta passkeys.", "danger")
    return
  }

  setAuthStatus(root, "[data-passkey-setup-status]", "Abrindo verificacao do dispositivo...", "info")

  await withPasskeyCeremony(async () => {
    const options = await jsonFetch("/passkeys/registration/options")
    const credential = await navigator.credentials.create({ publicKey: prepareCreateOptions(options) })
    const payload = await jsonFetch("/passkeys/registration", { publicKeyCredential: credentialToJson(credential) })

    setAuthStatus(root, "[data-passkey-setup-status]", payload.message, "success")
    window.location.href = payload.redirect_url
  })
}

const loginWithPasskey = async (root) => {
  if (!window.PublicKeyCredential) {
    setAuthStatus(root, "[data-passkey-login-status]", "Este navegador nao suporta passkeys.", "danger")
    return
  }

  const email = root.querySelector("[data-passkey-login-email]")?.value.trim()

  if (!email) {
    setAuthStatus(root, "[data-passkey-login-status]", "Informe o e-mail para buscar a passkey.", "warning")
    return
  }

  setAuthStatus(root, "[data-passkey-login-status]", "Abrindo biometria do dispositivo...", "info")

  await withPasskeyCeremony(async () => {
    const options = await jsonFetch("/passkeys/authentication/options", { email })
    const credential = await navigator.credentials.get({ publicKey: prepareGetOptions(options) })
    const payload = await jsonFetch("/passkeys/authentication", { publicKeyCredential: credentialToJson(credential) })

    setAuthStatus(root, "[data-passkey-login-status]", payload.message, "success")
    window.location.href = payload.redirect_url
  })
}

document.addEventListener("click", (event) => {
  const setupButton = event.target.closest("[data-passkey-register-account]")
  const loginButton = event.target.closest("[data-passkey-login-button]")

  if (setupButton) {
    event.preventDefault()
    const root = setupButton.closest("[data-passkey-setup]")
    registerAccountPasskey(root).catch((error) => {
      setAuthStatus(root, "[data-passkey-setup-status]", error.message, "danger")
    })
  }

  if (loginButton) {
    event.preventDefault()
    const root = loginButton.closest("[data-passkey-login]")
    loginWithPasskey(root).catch((error) => {
      setAuthStatus(root, "[data-passkey-login-status]", error.message, "danger")
    })
  }
})

document.addEventListener("input", (event) => {
  if (!event.target.matches("[data-passkey-email]")) return

  const passkeyEmail = document.querySelector("[data-passkey-login-email]")
  if (passkeyEmail) passkeyEmail.value = event.target.value
})

let internalNavigationStartedAt = 0

document.addEventListener("click", (event) => {
  if (event.target.closest("a, button[type='submit'], input[type='submit']")) {
    internalNavigationStartedAt = Date.now()
  }
})

document.addEventListener("submit", () => {
  internalNavigationStartedAt = Date.now()
})

document.addEventListener("visibilitychange", () => {
  if (document.visibilityState !== "hidden") return
  if (document.body.dataset.loggedIn !== "true") return
  if (window.financialManagerPasskeyBusy) return
  if (Date.now() - internalNavigationStartedAt < 2500) return

  navigator.sendBeacon?.("/session/close")
})
