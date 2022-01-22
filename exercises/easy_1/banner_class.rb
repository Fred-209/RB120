=begin

Behold this incomplete class for constructing boxed banners.

class Banner
  def initialize(message)
  end

  def to_s
    [horizontal_rule, empty_line, message_line, empty_line, horizontal_rule].join("\n")
  end

  private

  def horizontal_rule
  end

  def empty_line
  end

  def message_line
    "| #{@message} |"
  end
end

Complete this class so that the test cases shown below work as intended. You are free to add 
any methods or instance variables you need. However, do not make the implementation details public.

You may assume that the input will always fit in your terminal window.

Test Cases

banner = Banner.new('To boldly go where no one has gone before.')
puts banner
+--------------------------------------------+
|                                            |
| To boldly go where no one has gone before. |
|                                            |
+--------------------------------------------+

banner = Banner.new('')
puts banner
+--+
|  |
|  |
|  |
+--+


*Input*: string (maybe empty)

*Output*: visual representation of a banner with the given string 
as the text in the banner. 

*Explicit and inferred rules*
- make all implementation details not public
- complete the class so that test cases work as intended
- use any methods or instance variables I need. 
- The input will always fit in the terminal window
- the predfined `to_s` method shows that I will need the following instance methods/variables:
  - horizontal_rule, empty_line, message_line
- Will need to code an `initialization` method as the test cases show Banner objects being
created with `.new`.
- The format for the banner is a horizontal line of '-' across the screen, with a '+' char on each
end.
  - This is followed by a line of all empty spaces, with a '|' on each end
  - Followed by a '|' char, a space, the given message, a space, then a '|' char
  - Another line of spaces with '|' end caps
  - another line of '-' with '+' end caps. 
- The length of each line will be 4 chars longer than the length of the given message
  - This can determine the padding for each line. 


**Examples/Test Cases**

*Edge Cases*:
- code for a given empty string upon Banner object creation

**Data Structure**


**Algorithm**

*High level thought process / brainstorming ideas

*horizontal_rule*
- could be a private instance method
- needs to return a string
- the string should consist of '+ (variable amount of dashes) + '+'
- the number of dashes should be equal to the length of the string given upon Banner 
  minus 2

*empty_line*
- end caps of '|'
- spaces in the middle
- number of spaces is equal to string_length - 2



*Lower level steps of implementation*

=end

class Banner
  def initialize(message, banner_width=nil)
    @message = message  

    if banner_width
      @banner_width = banner_width
    else
      @banner_width = message.length + 4
    end
  end

  def to_s
    [horizontal_rule, empty_line, message_line, empty_line, horizontal_rule].join("\n")
  end

  private

  def create_banner_line(end_cap_char, middle_char)
    middle_line_width = @banner_width - 2
    middle_line = middle_char * middle_line_width
    end_cap_char + middle_line + end_cap_char
  end

  def horizontal_rule
    end_cap = '+'
    middle_char = '-'
    create_banner_line(end_cap, middle_char)
  end

  def empty_line
    end_cap = '|'
    middle_char = ' '
    create_banner_line(end_cap, middle_char)
  end

  def message_line
    "| #{@message} |"
  end
end

banner = Banner.new('To boldly go where no one has gone before.')
puts banner
banner = Banner.new('')
puts banner


# +--------------------------------------------+
# |                                            |
# | To boldly go where no one has gone before. |
# |                                            |
# +--------------------------------------------+
