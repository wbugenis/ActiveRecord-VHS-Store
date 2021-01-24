class Vhs < ActiveRecord::Base
    after_initialize :add_serial_number

    has_many :rentals
    has_many :clients, through: :rentals
    belongs_to :movie


    def is_available?
        self.rentals.all?{ |rental| rental.current == false} || self.rentals == []
    end

    # Vhs.hot_from_the_press - accepts arguments used to create a new instance of a Movie and a name of a genre; creates the movie, associates it with appropriate genre (if it exists, if it doesn't - creates one) and creates three instances of a Vhs associated with that Movie
    def self.hot_from_the_press(movie_info, genre_name)
        new_movie = Movie.create(movie_info)
        if !Genre.names.include?(genre_name)
            genre = Genre.create(name: genre_name)
        else
            genre = Genre.all.find_by(name: genre_name)
        end
        MovieGenre.create(movie_id: new_movie.id, genre_id: genre.id)
        3.times{ Vhs.create(movie_id: new_movie.id) }
    end

    # Vhs.most_used - prints a list of 3 vhs that have been most rented in the format: "serial number: 1111111 | title: 'movie title'
    def self.most_used
        sorted_vhs = Vhs.all.sort_by{ |vhs| vhs.rentals.count}.reverse!
        sliced_vhs = sorted_vhs.slice(0..2)
        sliced_vhs.each{ |vhs| puts "#{vhs.serial_number} | #{vhs.movie.title}"}
    end

    # Vhs.available_now - returns a list of all vhs currently available at the store
    def self.available_now
        Vhs.all.select{ |vhs| vhs.is_available?}
    end

    # # Vhs.all_genres - returns a list of all genres available at the store
    def self.all_genres
        Vhs.available_now.map{|vhs| vhs.movie.genres}.flatten.uniq
    end

    private

    # generates serial number based on the title
    def add_serial_number
        serial_number = serial_number_stub
        # Converting to Base 36 can be useful when you want to generate random combinations of letters and numbers, since it counts using every number from 0 to 9 and then every letter from a to z. Read more about base 36 here: https://en.wikipedia.org/wiki/Senary#Base_36_as_senary_compression
        alphanumerics = (0...36).map{ |i| i.to_s 36 }
        13.times{|t| serial_number << alphanumerics.sample}
        self.update(serial_number: serial_number)
    end

    def long_title?
        self.movie.title && self.movie.title.length > 2
    end

    def two_part_title?
        self.movie.title.split(" ")[1] && self.movie.title.split(" ")[1].length > 2
    end

    def serial_number_stub
        return "X" if self.movie.title.nil?
        return self.movie.title.split(" ")[1][0..3].gsub(/s/, "").upcase + "-" if two_part_title?
        return self.movie.title.gsub(/s/, "").upcase + "-" unless long_title?
        self.movie.title[0..3].gsub(/s/, "").upcase + "-"
    end

end