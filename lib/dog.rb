class Dog
    @@all = []
    attr_accessor :name, :breed
    attr_reader :id

    def initialize(id:nil, name:, breed:)
        @id = id
        @name = name
        @breed = breed
        @@all << self
    end

    def self.create_table
        sql = <<-SQL
        CREATE TABLE IF NOT EXISTS dogs (
          id INTEGER PRIMARY KEY,
          name TEXT,
          breed TEXT
        )
        SQL
        DB[:conn].execute(sql).map do |row|
            self.new_from_db(row)
        end
    end

    def self.drop_table
        sql = "DROP TABLE IF EXISTS dogs"
        DB[:conn].execute(sql)
    end

    def self.create(hash)
        p "create"
        name = hash.values_at(:name)[0]
        breed = hash.values_at(:breed)[0]

        new_dog = self.new(name: name,breed: breed)
        puts "new_dog:"
        p new_dog
        puts "-----------------"
        new_dog.save
    end

    def self.new_from_db(array)
        p "new_from_db"
        p array
        new_dog = self.new(id: array[0], name: array[1], breed: array[2])
        new_dog.save
        puts "new_dog:"
        p new_dog
        puts "-----------------"
        return new_dog
    end

    def self.find_by_id(id)
        p "find_by_id"
        p id
        idtest = nil
        sql = <<-SQL
            SELECT *
            FROM dogs
            WHERE id = ?
        SQL
  
      DB[:conn].execute(sql, id).map do |row|
        idtest = self.new_from_db(row)
      end.first
      puts "idtest:"
      p idtest
      puts "-----------------"
      return idtest
    end

    def self.find_or_create_by(hash)
        p "find_or_create_by"
        p hash
        name = hash.values_at(:name)[0]
        breed = hash.values_at(:breed)[0]
        id = nil
        sql = <<-SQL
            SELECT *
            FROM dogs
            WHERE name = ? AND breed = ?
        SQL
        id = DB[:conn].execute(sql, name, breed)
        p id
        if id.empty? == false
            self.find_by_id(id[0][0])
        else
            self.create(hash)
        end
    end

    def self.find_by_name(name)
        p "find_by_name"
        id = nil
        sql = <<-SQL
            SELECT *
            FROM dogs
            WHERE name = ?
        SQL
        id = DB[:conn].execute(sql, name)
        p id
        if id.empty? == false
            self.find_by_id(id[0][0])
        end
    end

    def update
        p "update"
        sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
        DB[:conn].execute(sql, self.name, self.breed, self.id)
      end

    def save
        p "save"
        if self.id
            p self.id
            self.update
        else
            sql = <<-SQL
                INSERT INTO dogs (name, breed)
                VALUES (?, ?)
            SQL
            DB[:conn].execute(sql, self.name, self.breed)
            @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
            p self
            puts "-----------------"
            self
        end
    end
end