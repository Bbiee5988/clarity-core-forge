;; Registry contract for managing app deployments

;; Constants
(define-constant err-unauthorized (err u100))

;; Data structures
(define-map deployments
  { app-id: uint, network: (string-ascii 16) }
  {
    contract-address: principal,
    deployed-at: uint,
    version: (string-ascii 16)
  }
)

;; Public functions
(define-public (register-deployment 
  (app-id uint)
  (network (string-ascii 16))
  (contract-address principal)
  (version (string-ascii 16))
)
  (let
    (
      (core-contract (contract-call? .core-forge get-app app-id))
    )
    (asserts! (is-some core-contract) err-unauthorized)
    (map-set deployments
      {app-id: app-id, network: network}
      {
        contract-address: contract-address,
        deployed-at: block-height,
        version: version
      }
    )
    (ok true)
  )
)

;; Read only functions
(define-read-only (get-deployment (app-id uint) (network (string-ascii 16)))
  (ok (map-get? deployments {app-id: app-id, network: network}))
)
