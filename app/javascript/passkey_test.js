const STORAGE_KEY = "financial_manager.passkey_test_credential"

const toBase64Url = (buffer) => {
  const bytes = new Uint8Array(buffer)
  let value = ""

  bytes.forEach((byte) => {
    value += String.fromCharCode(byte)
  })

  return btoa(value).replace(/\+/g, "-").replace(/\//g, "_").replace(/=+$/g, "")
}

const fromBase64Url = (value) => {
  const base64 = value.replace(/-/g, "+").replace(/_/g, "/")
  const padded = base64.padEnd(Math.ceil(base64.length / 4) * 4, "=")
  const binary = atob(padded)
  const bytes = new Uint8Array(binary.length)

  for (let index = 0; index < binary.length; index += 1) {
    bytes[index] = binary.charCodeAt(index)
  }

  return bytes
}

const randomBytes = (size = 32) => {
  const bytes = new Uint8Array(size)
  crypto.getRandomValues(bytes)
  return bytes
}

const statusBox = (root) => root.querySelector("[data-passkey-status]")

const setStatus = (root, message, variant = "secondary") => {
  const box = statusBox(root)
  if (!box) return

  box.className = `alert alert-${variant} mb-0`
  box.textContent = message
}

const checkSupport = async (root) => {
  if (!window.PublicKeyCredential) {
    setStatus(root, "WebAuthn nao esta disponivel neste navegador.", "danger")
    return false
  }

  if (!window.isSecureContext) {
    setStatus(root, "WebAuthn exige HTTPS ou localhost. No TWA publicado, use a origem HTTPS validada.", "warning")
    return false
  }

  const platformAuthenticatorAvailable =
    await PublicKeyCredential.isUserVerifyingPlatformAuthenticatorAvailable()

  if (!platformAuthenticatorAvailable) {
    setStatus(root, "Navegador OK, mas nenhum autenticador biometrico/de plataforma foi encontrado.", "warning")
    return false
  }

  setStatus(root, "Suporte encontrado. O proximo passo deve abrir a confirmacao do Android.", "success")
  return true
}

const registerCredential = async (root) => {
  if (!(await checkSupport(root))) return

  const credential = await navigator.credentials.create({
    publicKey: {
      challenge: randomBytes(),
      rp: {
        name: "Financial Manager"
      },
      user: {
        id: randomBytes(16),
        name: "teste@financial-manager.local",
        displayName: "Teste Biometria"
      },
      pubKeyCredParams: [
        { type: "public-key", alg: -7 },
        { type: "public-key", alg: -257 }
      ],
      authenticatorSelection: {
        authenticatorAttachment: "platform",
        residentKey: "preferred",
        requireResidentKey: false,
        userVerification: "required"
      },
      attestation: "none",
      timeout: 60000
    }
  })

  const transports = credential.response.getTransports ? credential.response.getTransports() : undefined

  localStorage.setItem(
    STORAGE_KEY,
    JSON.stringify({
      id: credential.id,
      rawId: toBase64Url(credential.rawId),
      transports
    })
  )

  setStatus(root, "Passkey de teste criada neste aparelho. Agora toque em Testar autenticacao.", "success")
}

const authenticateCredential = async (root) => {
  if (!(await checkSupport(root))) return

  const storedCredential = JSON.parse(localStorage.getItem(STORAGE_KEY) || "null")
  const allowCredentials = storedCredential
    ? [
        {
          id: fromBase64Url(storedCredential.rawId),
          type: "public-key",
          transports: storedCredential.transports
        }
      ]
    : []

  const credential = await navigator.credentials.get({
    publicKey: {
      challenge: randomBytes(),
      allowCredentials,
      userVerification: "required",
      timeout: 60000
    }
  })

  setStatus(root, `Autenticacao concluida com a credencial ${credential.id}.`, "success")
}

const clearCredential = (root) => {
  localStorage.removeItem(STORAGE_KEY)
  setStatus(root, "Teste local limpo. A passkey pode continuar no gerenciador do aparelho.", "secondary")
}

const bindPasskeyTest = (root) => {
  root.querySelector("[data-passkey-check]")?.addEventListener("click", () => {
    checkSupport(root).catch((error) => setStatus(root, error.message, "danger"))
  })

  root.querySelector("[data-passkey-register]")?.addEventListener("click", () => {
    registerCredential(root).catch((error) => setStatus(root, error.message, "danger"))
  })

  root.querySelector("[data-passkey-authenticate]")?.addEventListener("click", () => {
    authenticateCredential(root).catch((error) => setStatus(root, error.message, "danger"))
  })

  root.querySelector("[data-passkey-clear]")?.addEventListener("click", () => {
    clearCredential(root)
  })
}

document.addEventListener("turbo:load", () => {
  document.querySelectorAll("[data-passkey-test]").forEach(bindPasskeyTest)
})
