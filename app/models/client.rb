class Client < ActiveRecord::Base

    has_many :rentals
    has_many :vhs, through: :rentals

    #Return all movies a client has rented
    def movies
        Vhs.map{ |vhs| vhs.movie.title}
    end

    def genres
        movies.map(&:genres).flatten
    end

    # Client.first_rental - accepts and instance of arguments needed to create a new Client instance (name, home address) and a currently available Vhs instance (or, more difficult: a Movie instance or just a Movie title and on that basis chooses a currently available vhs); it creates a new Client instance and a new Rental instance with current set to true.
    def self.first_rental(client_info, vhs)
        client = Client.create(client_info)
        if !Rental.all.find_by(vhs: vhs).current
            Rental.create(client_id: client.id, vhs_id: vhs.id, current: true)
        else 
            "VHS is already rented! Sorry."
        end
    end

    # Client.most_active - returns a list of top 5 most active clients (i.e. those who had the most non-current / returned rentals)
    def self.most_active
        sorted_clients = Client.all.sort_by{ |client| client.rentals.count}
        sorted_clients.reverse!.slice(0..4)
    end

    # Client#return_one - accepts an argument of an vhs instance, finds the corresponding rental and updates the rental's current attribute from true to false
    def return_one(vhs)
        Rental.all.find_by(vhs_id: vhs.id).update(current: false)
    end

    # Client#favorite_genre ⭐️ - puts the name of the genre that the client rented the most; in counting how many times a person watched a genre, you can treat two rentals of the same movie as two separate instances;
    def favorite_genre
        genre_hash = {}
        genres.each{ |genre| 
            if genre_hash[genre.name]
                genre_hash[genre.name] += 1
            else
                genre_hash[genre.name] = 1
            end
        }
        max_hash = genre_hash.max_by{ |key, value| value }
        max_hash.key
    end


    # Client#return_all- updates current attribute from true to false on all client's rentals
    def return_all
        Rental.all.select{ |rental| rental.client == self}.each{ |rental| rental.update(current: false)}
    end

    # Client#last_return - updates all Client' rentals current to false and deletes the Client from the database
    def last_return
        return_all
        self.destroy
    end

end