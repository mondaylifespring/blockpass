;; contracts/event-pass.clar

(define-constant ERR_NOT_ORGANIZER u100)
(define-constant ERR_TICKET_EXISTS u101)
(define-constant ERR_TICKET_NOT_FOUND u102)
(define-constant ERR_NOT_TICKET_OWNER u103)
(define-constant ERR_TICKET_ALREADY_SOLD u104)

(define-data-var ticket-counter uint u0)
(define-map tickets uint 
    (tuple (owner principal) (price uint) (sold bool)))
(define-map balances principal uint)

(define-public (mint-ticket (ticket-id uint) (price uint))
    (begin
        ;; Ensure only the contract deployer (organizer) can mint tickets
        (asserts! (is-eq tx-sender (as-contract tx-sender)) (err ERR_NOT_ORGANIZER))
        ;; Ensure the ticket doesn't already exist
        (asserts! (is-none (map-get? tickets ticket-id)) (err ERR_TICKET_EXISTS))
        ;; Ensure price is valid (non-negative)
        (asserts! (>= price u0) (err u107))
        ;; Store the ticket with the initial state
        (map-set tickets ticket-id { owner: tx-sender, price: price, sold: false })
        ;; Increment ticket counter
        (var-set ticket-counter (+ (var-get ticket-counter) u1))
        ;; Verify the ticket was created successfully
        (match (map-get? tickets ticket-id)
            ticket-data (ok ticket-id)
            (err ERR_TICKET_NOT_FOUND)
        )
    )
)

(define-public (buy-ticket (ticket-id uint))
    (let (
        (ticket (map-get? tickets ticket-id))
    )
        (begin
            ;; Ensure the ticket exists
            (asserts! (is-some ticket) (err ERR_TICKET_NOT_FOUND))
            ;; Unwrap the ticket data
            (let (
                (ticket-data (unwrap-panic ticket))
                (ticket-price (get price ticket-data))
                (ticket-owner (get owner ticket-data))
                (ticket-sold (get sold ticket-data))
            )
                ;; Ensure the ticket is not already sold
                (asserts! (not ticket-sold) (err ERR_TICKET_ALREADY_SOLD))
                ;; Ensure the buyer pays enough funds
                (match (stx-transfer? ticket-price tx-sender ticket-owner)
                    success
                    (begin
                        ;; Transfer the ticket to the buyer
                        (map-set tickets ticket-id { owner: tx-sender, price: ticket-price, sold: true })
                        ;; Update balances for organizer
                        (let ((current-balance (default-to u0 (map-get? balances ticket-owner))))
                            (map-set balances ticket-owner (+ current-balance ticket-price))
                        )
                        (ok ticket-id)
                    )
                    error (err u106)
                )
            )
        )
    )
)

(define-public (transfer-ticket (ticket-id uint) (recipient principal))
    (let (
        (ticket (map-get? tickets ticket-id))
    )
        (begin
            ;; Ensure the ticket exists
            (asserts! (is-some ticket) (err ERR_TICKET_NOT_FOUND))
            ;; Unwrap the ticket data
            (let (
                (ticket-data (unwrap-panic ticket))
                (ticket-owner (get owner ticket-data))
            )
                ;; Ensure the caller owns the ticket
                (asserts! (is-eq ticket-owner tx-sender) (err ERR_NOT_TICKET_OWNER))
                ;; Ensure recipient is not null
                (asserts! (is-some (some recipient)) (err u108))
                ;; Transfer ticket ownership
                (map-set tickets ticket-id { owner: recipient, price: (get price ticket-data), sold: true })
                (ok recipient)
            )
        )
    )
)

(define-public (withdraw-funds)
    (let (
        (balance (default-to u0 (map-get? balances tx-sender)))
    )
        (begin
            ;; Ensure the user has funds to withdraw
            (asserts! (> balance u0) (err u105))
            ;; Transfer funds to the user
            (match (stx-transfer? balance (as-contract tx-sender) tx-sender)
                success (begin
                    ;; Reset balance to zero only if transfer succeeded
                    (map-delete balances tx-sender)
                    (ok balance)
                )
                error (err u106)
            )
        )
    )
)
