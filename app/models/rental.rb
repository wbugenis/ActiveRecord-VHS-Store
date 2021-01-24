class Rental < ActiveRecord::Base
    
    belongs_to :client 
    belongs_to :vhs

    # Rental#due_date - returns a date one week from when the record was created
    def due_date
        self.created_at + 7.days
    end

    # Rental.past_due_date - returns a list of all the rentals past due date, currently rented or rented in the past
    def self.past_due_date
        Rental.all.select{ |rental| rental.due_date < Time.now}
    end

end
