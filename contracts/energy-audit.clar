
(define-constant ERR-UNAUTHORIZED (err u100))
(define-constant ERR-NOT-FOUND (err u101))
(define-constant ERR-INVALID-VALUE (err u102))

(define-data-var facility-admin principal tx-sender)

(define-map facilities
  { facility-id: uint }
  {
    name: (string-ascii 100),
    total-sqft: uint,
    current-consumption: uint,
    audit-status: (string-ascii 20),
    last-audit-date: uint
  }
)

(define-map equipment-assessments
  { facility-id: uint, equipment-id: uint }
  {
    equipment-type: (string-ascii 50),
    efficiency-rating: uint,
    replacement-cost: uint,
    savings-potential: uint
  }
)

(define-map improvement-recommendations
  { facility-id: uint, rec-id: uint }
  {
    description: (string-ascii 200),
    estimated-savings: uint,
    implementation-cost: uint,
    priority: uint
  }
)

(define-data-var next-facility-id uint u0)
(define-data-var next-rec-id uint u0)

(define-public (register-facility (name (string-ascii 100)) (sqft uint))
  (let ((fac-id (var-get next-facility-id)))
    (begin
      (map-insert facilities
        { facility-id: fac-id }
        {
          name: name,
          total-sqft: sqft,
          current-consumption: u0,
          audit-status: "pending",
          last-audit-date: u1
        }
      )
      (var-set next-facility-id (+ fac-id u1))
      (ok fac-id)
    )
  )
)

(define-public (record-equipment-assessment (facility-id uint) (equipment-id uint) (eq-type (string-ascii 50)) (rating uint) (replacement uint) (savings uint))
  (begin
    (map-insert equipment-assessments
      { facility-id: facility-id, equipment-id: equipment-id }
      {
        equipment-type: eq-type,
        efficiency-rating: rating,
        replacement-cost: replacement,
        savings-potential: savings
      }
    )
    (ok true)
  )
)

(define-public (add-improvement-recommendation (facility-id uint) (description (string-ascii 200)) (est-savings uint) (impl-cost uint) (priority uint))
  (let ((rec-id (var-get next-rec-id)))
    (begin
      (map-insert improvement-recommendations
        { facility-id: facility-id, rec-id: rec-id }
        {
          description: description,
          estimated-savings: est-savings,
          implementation-cost: impl-cost,
          priority: priority
        }
      )
      (var-set next-rec-id (+ rec-id u1))
      (ok rec-id)
    )
  )
)

(define-public (update-facility-consumption (facility-id uint) (new-consumption uint))
  (let ((facility (map-get? facilities { facility-id: facility-id })))
    (match facility
      fac-data
        (ok (map-set facilities
          { facility-id: facility-id }
          (merge fac-data { current-consumption: new-consumption })
        ))
      (err ERR-NOT-FOUND)
    )
  )
)

(define-read-only (get-facility (facility-id uint))
  (map-get? facilities { facility-id: facility-id })
)

(define-read-only (get-equipment-assessment (facility-id uint) (equipment-id uint))
  (map-get? equipment-assessments { facility-id: facility-id, equipment-id: equipment-id })
)

(define-read-only (get-recommendation (facility-id uint) (rec-id uint))
  (map-get? improvement-recommendations { facility-id: facility-id, rec-id: rec-id })
)

