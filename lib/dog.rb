class Dog
        attr_accessor :id, :name, :breed
    def initialize(id:nil, name:, breed:)
        @id = id
        @name = name
        @breed = breed
    end

    def self.drop_table
        sql = <<-SQL
        DROP TABLE IF EXISTS dogs
        SQL

        DB[:conn].execute(sql)
    end

    def self.create_table
        sql = <<-SQL
        CREATE TABLE IF NOT EXISTS dogs (
            id INTEGER PRIMARY KEY,
            name TEXT,
            breed TEXT
        )
        SQL
        DB[:conn].execute(sql)
    end
    def save
        sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?, ?)
        SQL

        # insert the dog
        DB[:conn].execute(sql, self.name, self.breed)

        # get the dog ID from the database and save it to the Ruby instance
        self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]

        # return the Ruby instance
        self
    end

    def self.create(name:, breed:)
        dog = Dog.new(name:name, breed:breed)
        dog.save
    end

    #creates an instance with corresponding attribute
    def self.new_from_db(row)
        self.new(id: row[0], name: row[1], breed:row[2])
    end

    #return an array of Dog instances for every record in the dogs table
    def self.all
        sql = <<-SQL
        SELECT *
        FROM dogs
        SQL

        DB[:conn].execute(sql).map{|row| self.new_from_db(row)}
    end

    def self.find_by_name(name)
        sql = <<-SQL
        SELECT * 
        FROM dogs
        WHERE name = ?
        LIMIT 1
        SQL

        DB[:conn].execute(sql, name).map{|row| self.new_from_db(row)}.first
    end

    def self.find(id)
        sql = <<-SQL
        SELECT * 
        FROM dogs
        WHERE id = ?
        LIMIT 1
        SQL

        DB[:conn].execute(sql, id).map{|row| self.new_from_db(row)}.first
    end
end
