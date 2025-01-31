;; Core contract for the CoreForge platform

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-already-exists (err u102))

;; Data structures
(define-map apps 
  { app-id: uint }
  {
    owner: principal,
    name: (string-ascii 64),
    description: (string-utf8 256),
    created-at: uint,
    status: (string-ascii 16)
  }
)

(define-data-var next-app-id uint u1)

;; Public functions
(define-public (create-app (name (string-ascii 64)) (description (string-utf8 256)))
  (let
    (
      (app-id (var-get next-app-id))
    )
    (asserts! (is-none (map-get? apps {app-id: app-id})) err-already-exists)
    (map-set apps
      {app-id: app-id}
      {
        owner: tx-sender,
        name: name,
        description: description,
        created-at: block-height,
        status: "active"
      }
    )
    (var-set next-app-id (+ app-id u1))
    (ok app-id)
  )
)

(define-public (update-app-status (app-id uint) (new-status (string-ascii 16)))
  (let
    (
      (app (unwrap! (map-get? apps {app-id: app-id}) err-not-found))
    )
    (asserts! (is-eq tx-sender (get owner app)) err-owner-only)
    (map-set apps
      {app-id: app-id}
      (merge app {status: new-status})
    )
    (ok true)
  )
)

;; Read only functions
(define-read-only (get-app (app-id uint))
  (ok (map-get? apps {app-id: app-id}))
)

(define-read-only (get-app-count)
  (ok (- (var-get next-app-id) u1))
)
