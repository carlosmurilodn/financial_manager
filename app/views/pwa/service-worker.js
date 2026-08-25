const CACHE_NAME = "financial-manager-v2"
const CACHE_URLS = ["/icon.png"]

self.addEventListener("install", (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME).then((cache) => cache.addAll(CACHE_URLS))
  )
  self.skipWaiting()
})

self.addEventListener("activate", (event) => {
  event.waitUntil(
    caches.keys().then((cacheNames) =>
      Promise.all(
        cacheNames
          .filter((cacheName) => cacheName !== CACHE_NAME)
          .map((cacheName) => caches.delete(cacheName))
      )
    )
  )
  self.clients.claim()
})

self.addEventListener("fetch", (event) => {
  if (event.request.method !== "GET") return

  event.respondWith(
    fetch(event.request).catch(async () => {
      const cachedResponse = await caches.match(event.request)
      if (cachedResponse) return cachedResponse

      return new Response("Serviço temporariamente indisponível.", {
        status: 503,
        statusText: "Service Unavailable",
        headers: { "Content-Type": "text/plain; charset=utf-8" }
      })
    })
  )
})
