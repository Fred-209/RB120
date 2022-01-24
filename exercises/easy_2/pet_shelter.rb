=begin


butterscotch = Pet.new('cat', 'Butterscotch')
pudding      = Pet.new('cat', 'Pudding')
darwin       = Pet.new('bearded dragon', 'Darwin')
kennedy      = Pet.new('dog', 'Kennedy')
sweetie      = Pet.new('parakeet', 'Sweetie Pie')
molly        = Pet.new('dog', 'Molly')
chester      = Pet.new('fish', 'Chester')

phanson = Owner.new('P Hanson')
bholmes = Owner.new('B Holmes')

shelter = Shelter.new
shelter.adopt(phanson, butterscotch)
shelter.adopt(phanson, pudding)
shelter.adopt(phanson, darwin)
shelter.adopt(bholmes, kennedy)
shelter.adopt(bholmes, sweetie)
shelter.adopt(bholmes, molly)
shelter.adopt(bholmes, chester)
shelter.print_adoptions
puts "#{phanson.name} has #{phanson.number_of_pets} adopted pets."
puts "#{bholmes.name} has #{bholmes.number_of_pets} adopted pets."



Write the classes and methods that will be necessary to make this code run, and print the following output:

P Hanson has adopted the following pets:
a cat named Butterscotch
a cat named Pudding
a bearded dragon named Darwin

B Holmes has adopted the following pets:
a dog named Molly
a parakeet named Sweetie Pie
a dog named Kennedy
a fish named Chester

P Hanson has 3 adopted pets.
B Holmes has 4 adopted pets.
=end


class Shelter

  def initialize
    @adoption_records = {}
    @sheltered_pets = []
  end
  
  def shelter_pet(pet)
    @sheltered_pets << pet
  end
  
  def remove_pet_from_shelter(pet)
    @sheltered_pets.delete(pet)
  end

  def adopt(owner, pet)
    if @adoption_records.has_key?(owner)
      @adoption_records[owner] << pet
    else
      @adoption_records[owner] = [pet]
    end
    owner.adopted_pets << pet
    remove_pet_from_shelter(pet)
  end

  def unadopted_count
    @sheltered_pets.count
  end

  def list_sheltered_pets
    puts "The Animal Shelter has the following pets available for adoption:"
    @sheltered_pets.each do |pet|
      puts "A #{pet.type} named #{pet.name}."
    end
  end

  def print_adoptions
    @adoption_records.each_pair do |owner, adopted_pets|
      puts "#{owner.name} has adopted the following pets:"
      adopted_pets.each do |pet|
        puts "a #{pet.type} named #{pet.name}"
      end
      puts
    end
  end
end

class Pet
  attr_reader :type, :name

  def initialize(type, name)
    @type = type
    @name = name
  end
end

class Owner
  attr_reader :name
  attr_accessor :adopted_pets

  def initialize(name)
    @name = name
    @adopted_pets = []
  end

  def number_of_pets
    @adopted_pets.size
  end

end

butterscotch = Pet.new('cat', 'Butterscotch')
pudding      = Pet.new('cat', 'Pudding')
darwin       = Pet.new('bearded dragon', 'Darwin')
kennedy      = Pet.new('dog', 'Kennedy')
sweetie      = Pet.new('parakeet', 'Sweetie Pie')
molly        = Pet.new('dog', 'Molly')
chester      = Pet.new('fish', 'Chester')
bebe         = Pet.new('dog', 'Bebe')
pablo        = Pet.new('dog', 'Pablo')
asta         = Pet.new('dog', 'Asta')
laddie       = Pet.new('dog', 'Laddie')
fluffy       = Pet.new('cat', 'Fluffy')
kat          = Pet.new('cat', 'Kat')
ben          = Pet.new('cat', 'Ben')
chatterbox   = Pet.new('parakeet', 'Chatterbox')
bluebell     = Pet.new('parakeet', 'Bluebell')


fdurham = Owner.new('F Durham')
phanson = Owner.new('P Hanson')
bholmes = Owner.new('B Holmes')

shelter = Shelter.new

shelter.shelter_pet(butterscotch)
shelter.shelter_pet(pudding)
shelter.shelter_pet(darwin)
shelter.shelter_pet(kennedy)
shelter.shelter_pet(sweetie) 
shelter.shelter_pet(molly)
shelter.shelter_pet(chester)
shelter.shelter_pet(bebe)
shelter.shelter_pet(pablo)
shelter.shelter_pet(asta)
shelter.shelter_pet(laddie)
shelter.shelter_pet(fluffy)
shelter.shelter_pet(kat)
shelter.shelter_pet(ben)
shelter.shelter_pet(chatterbox)
shelter.shelter_pet(bluebell)


shelter.adopt(phanson, butterscotch)
shelter.adopt(phanson, pudding)
shelter.adopt(phanson, darwin)
shelter.adopt(bholmes, kennedy)
shelter.adopt(bholmes, sweetie)
shelter.adopt(bholmes, molly)
shelter.adopt(bholmes, chester)
shelter.adopt(fdurham, bebe)
shelter.adopt(fdurham, pablo)
shelter.print_adoptions
puts "#{phanson.name} has #{phanson.number_of_pets} adopted pets."
puts "#{bholmes.name} has #{bholmes.number_of_pets} adopted pets."
puts "#{fdurham.name} has #{fdurham.number_of_pets} adopted pets."
puts "The Animal Shelter has #{shelter.unadopted_count} unadopted pets."
puts "The following animals are available to be adopted:"
puts ""

shelter.list_sheltered_pets
