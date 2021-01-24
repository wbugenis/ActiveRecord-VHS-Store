class Genre < ActiveRecord::Base
    has_many :movie_genres
    has_many :movies, through: :movie_genres

    #Returns all genre names
    def self.names
        Genre.all.map(&:name)
    end
end