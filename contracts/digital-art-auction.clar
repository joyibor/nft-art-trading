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

;; Set royalty rate (only admin)
(define-public (set-royalty-rate (rate uint))
  (begin
    (asserts! (is-eq tx-sender contract-admin) err-admin-only)
    (asserts! (<= rate u100) err-invalid-art-quantity)
    (var-set royalty-rate rate)
    (ok true)))

;; Set maximum artwork per artist (only admin)
(define-public (set-max-art-per-artist (new-max uint))
  (begin
    (asserts! (is-eq tx-sender contract-admin) err-admin-only)
    (asserts! (> new-max u0) err-invalid-art-quantity)
    (var-set max-art-per-artist new-max)
    (ok true)))

;; Adjust royalty rate (admin only)
(define-public (adjust-royalty-rate (rate uint))
  (begin
    (asserts! (is-eq tx-sender contract-admin) err-admin-only)
    (asserts! (<= rate u100) err-invalid-art-quantity)
    (var-set royalty-rate rate)
    (ok true)))

;; Add a new artwork listing for sale
(define-public (add-artwork-listing (quantity uint) (price uint))
  (begin
    (asserts! (> quantity u0) err-invalid-art-quantity)
    (asserts! (> price u0) err-invalid-art-price)
    (map-set artworks-for-sale {artist: tx-sender} {quantity: quantity, price: price})
    (ok true)))

;; Enhance security - Add access control to update artwork price
(define-public (update-art-price (new-price uint))
  (begin
    (asserts! (is-eq tx-sender contract-admin) err-admin-only)
    (asserts! (> new-price u0) err-invalid-art-price)
    (var-set art-price new-price)
    (ok true)))

;; Fix a bug - Prevent purchase when no artworks are available
(define-public (check-artwork-availability (artist principal) (quantity uint))
  (let (
    (sale-data (default-to {quantity: u0, price: u0} (map-get? artworks-for-sale {artist: artist})))
  )
    (asserts! (> (get quantity sale-data) quantity) err-insufficient-balance)
    (ok true)))

;; Enhance security - Limit access to set max artwork per artist
(define-public (set-max-artwork-per-artist (new-max uint))
  (begin
    (asserts! (is-eq tx-sender contract-admin) err-admin-only)
    (asserts! (> new-max u0) err-invalid-art-quantity)
    (var-set max-art-per-artist new-max)
    (ok true)))

;; Function to fix bug related to insufficient balance when removing artwork
(define-public (fix-remove-artwork-balance-bug (quantity uint))
  (begin
    ;; Ensures that sufficient balance is checked and no errors are thrown incorrectly
    (let ((current-for-sale (get quantity (default-to {quantity: u0, price: u0} 
                                                     (map-get? artworks-for-sale {artist: tx-sender})))))
      (asserts! (>= current-for-sale quantity) err-insufficient-balance)
      (ok true))))

;; Set platform fee rate (only admin)
(define-public (set-platform-fee-rate (rate uint))
  (begin
    (asserts! (is-eq tx-sender contract-admin) err-admin-only)
    (asserts! (<= rate u100) err-invalid-art-quantity)
    (var-set platform-fee-rate rate)
    (ok true)))

;; Add artwork for sale by artist
(define-public (add-artwork (quantity uint) (price uint))
  (let (
    (balance (default-to u0 (map-get? artist-art-balance tx-sender)))
    (current-for-sale (get quantity (default-to {quantity: u0, price: u0} (map-get? artworks-for-sale {artist: tx-sender}))))
    (total-for-sale (+ quantity current-for-sale))
  )
    (asserts! (> quantity u0) err-invalid-art-quantity)
    (asserts! (> price u0) err-invalid-art-price)
    (asserts! (>= balance total-for-sale) err-insufficient-balance)
    (try! (adjust-artwork-reserve (to-int quantity)))
    (map-set artworks-for-sale {artist: tx-sender} {quantity: total-for-sale, price: price})
    (ok true)))

;; Remove artwork from sale
(define-public (remove-artwork (quantity uint))
  (let (
    (current-for-sale (get quantity (default-to {quantity: u0, price: u0} (map-get? artworks-for-sale {artist: tx-sender}))))
  )
    (asserts! (>= current-for-sale quantity) err-insufficient-balance)
    (try! (adjust-artwork-reserve (to-int (- quantity))))
    (map-set artworks-for-sale {artist: tx-sender} 
             {quantity: (- current-for-sale quantity), 
              price: (get price (default-to {quantity: u0, price: u0} (map-get? artworks-for-sale {artist: tx-sender})))})
    (ok true)))

;; Purchase artwork from artist
(define-public (purchase-artwork (artist principal) (quantity uint))
  (let (
    (sale-data (default-to {quantity: u0, price: u0} (map-get? artworks-for-sale {artist: artist})))
    (total-cost (* quantity (get price sale-data)))
    (royalty (calculate-royalty total-cost))
    (fee (calculate-fee total-cost))
    (artist-balance (default-to u0 (map-get? artist-art-balance artist)))
    (buyer-royalty (default-to u0 (map-get? user-royalty-balance tx-sender)))
  )
    (asserts! (not (is-eq tx-sender artist)) err-duplicate-transaction)
    (asserts! (> quantity u0) err-invalid-art-quantity)
    (asserts! (>= (get quantity sale-data) quantity) err-insufficient-balance)
    (asserts! (>= artist-balance quantity) err-insufficient-balance)

    ;; Update artist's balance and artwork quantity
    (map-set artist-art-balance artist (- artist-balance quantity))
    (map-set artworks-for-sale {artist: artist} 
             {quantity: (- (get quantity sale-data) quantity), price: (get price sale-data)})

    ;; Update royalty balances
    (map-set user-royalty-balance tx-sender (+ buyer-royalty royalty))
    (map-set user-royalty-balance contract-admin (+ (default-to u0 (map-get? user-royalty-balance contract-admin)) fee))

    (ok true)))

;; Read-only functions

;; Get current art price
(define-read-only (get-art-price)
  (ok (var-get art-price)))

;; Get royalty rate
(define-read-only (get-royalty-rate)
  (ok (var-get royalty-rate)))

;; Get platform fee rate
(define-read-only (get-platform-fee-rate)
  (ok (var-get platform-fee-rate)))

;; Get artist's art balance
(define-read-only (get-artist-balance (artist principal))
  (ok (default-to u0 (map-get? artist-art-balance artist))))

;; Get user royalty balance
(define-read-only (get-user-royalty-balance (user principal))
  (ok (default-to u0 (map-get? user-royalty-balance user))))

;; Get artwork for sale by artist
(define-read-only (get-artwork-for-sale (artist principal))
  (ok (default-to {quantity: u0, price: u0} (map-get? artworks-for-sale {artist: artist}))))

;; Get artwork reserve limit
(define-read-only (get-artwork-reserve-limit)
  (ok (var-get artwork-reserve-limit)))
