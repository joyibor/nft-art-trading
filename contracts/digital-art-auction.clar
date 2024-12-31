;; Artwork Marketplace Smart Contract: nft-art-trading
;;
;; This Clarity smart contract enables artists to list their artworks for sale, set prices, and manage inventory.
;; It allows users to purchase artworks, calculates royalties for artists, and applies platform fees.
;; The contract includes administrative functions to set artwork prices, royalty rates, and platform fees.
;; It also enforces limits on the number of artworks an artist can list and the total number of artworks in the system.
;; The contract ensures secure transactions and maintains a reserve of artworks available for sale.


;; Define constants
(define-constant contract-admin tx-sender)
(define-constant err-admin-only (err u200))
(define-constant err-insufficient-balance (err u201))
(define-constant err-invalid-art-price (err u202))
(define-constant err-transfer-failed (err u203))
(define-constant err-invalid-art-quantity (err u204))
(define-constant err-ownership-failed (err u205))
(define-constant err-duplicate-transaction (err u206))
(define-constant err-reserve-limit-surpassed (err u207))

;; Define data variables
(define-data-var art-price uint u1000) ;; Price per artwork in microstacks
(define-data-var max-art-per-artist uint u100) ;; Max art pieces an artist can add
(define-data-var royalty-rate uint u10) ;; Royalty percentage (e.g., 10%)
(define-data-var platform-fee-rate uint u3) ;; Platform fee percentage
(define-data-var artwork-reserve-limit uint u50000) ;; Global artwork reserve limit
(define-data-var total-art-reserve uint u0) ;; Total art pieces in the system

;; Define data maps
(define-map artist-art-balance principal uint)
(define-map user-royalty-balance principal uint)
(define-map artworks-for-sale {artist: principal} {quantity: uint, price: uint})

;; Private functions

;; Calculate royalty
(define-private (calculate-royalty (price uint))
  (/ (* price (var-get royalty-rate)) u100))

;; Calculate platform fee
(define-private (calculate-fee (price uint))
  (/ (* price (var-get platform-fee-rate)) u100))

;; Update artwork reserve
(define-private (adjust-artwork-reserve (quantity int))
  (let (
    (current-reserve (var-get total-art-reserve))
    (new-reserve (if (< quantity 0)
                     (if (>= current-reserve (to-uint (- quantity)))
                         (- current-reserve (to-uint (- quantity)))
                         u0)
                     (+ current-reserve (to-uint quantity))))
  )
    (asserts! (<= new-reserve (var-get artwork-reserve-limit)) err-reserve-limit-surpassed)
    (var-set total-art-reserve new-reserve)
    (ok true)))

;; Fix a bug - Correct balance after artwork removal
(define-private (correct-artist-balance-after-removal (artist principal) (quantity uint))
  (let (
    (current-balance (default-to u0 (map-get? artist-art-balance artist)))
  )
    (map-set artist-art-balance artist (+ current-balance quantity))
    (ok true)))

;; Public functions

;; Set artwork price (only admin)
(define-public (set-art-price (price uint))
  (begin
    (asserts! (is-eq tx-sender contract-admin) err-admin-only)
    (asserts! (> price u0) err-invalid-art-price)
    (var-set art-price price)
    (ok true)))
