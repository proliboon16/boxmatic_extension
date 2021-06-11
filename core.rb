
require "sketchup.rb"

module TestPlugin
  class BoxMatic

    # BELOW ARE THE SKETCHUP CLASS METHODS

    # this will be called once the tool is
    # activated/clicked by the user
    def activate

      # Initialize InputPoint object
      @cursor = Sketchup::InputPoint.new
      puts "BoxMatic loaded"

      # two 2D points for calculating the square's dimensions
      @first_point = []
      @second_point = []

      @sides = 0.00

      #Sketchup.status_text = "BoxMatic loaded."
      Sketchup.vcb_label = "Sides"

    end

    # deactivate tool in certain situations
    def deactivate(view)
      view.invalidate
    end

    # resume and suspend functions eg. on drag-and-release
    def resume(view)
      view.invalidate
    end

    def suspend(view)
      view.invalidate
    end

    # cancel tool focus ; reset values of two points when
    # tool is cancelled
    def onCancel(reason, view)
      @first_point = []
      @second_point = []
      view.invalidate
    end

    def onMouseMove (flags, x, y, view)
      # display cursor coordinates on status text bar
      # as mouse is hovering over the view port
      @cursor.pick(view, x, y)
      @x, @y = @cursor.position.to_a
      Sketchup.status_text = "#{@x}, #{@y}"

      view.invalidate
    end # onMouseMove method

    # Define the first and second points on click that will calculate
    # the positions of the other two points to make a rectangle
    def onLButtonDown (flags, x, y, view)

      if @first_point.length > 0

        @second_point = [@x.round(2), @y.round(2)]
        @pt2 = @second_point
        puts "2nd point: #{@pt2}"
        @first_point.clear

        draw_square(@pt1, @pt2)
      else
        @first_point = [@x.round(2), @y.round(2)]
        @pt1 = [@x.round(2), @y.round(2)]
        puts "1st point: #{@pt1}"
      end

      view.invalidate
    end # onLButtonDown method

    def onSetCursor
      UI.set_cursor(632)
    end

    def enableVCB?
      return true
    end

    def onUserText (text, view)
      sides = text.to_f

      # If ONLY the first point is set by mouse click, we draw a square
      # using the value on the VCB user input for all sides
      if @first_point.length > 0 && @second_point.length == 0

        pt2 = [ @pt1[0]+sides, @pt1[1]+sides ]
        puts "@pt1 value: #{@pt1}"
        puts "pt2 value: #{pt2}"

        draw_square(@pt1, pt2)
      end

      puts "VCB value: #{@sides}"

      draw_square
      view.invalidate
    end

    # BELOW ARE THE CUSTOM METHODS

    # Draw a square on ground plane
    # based on the dimensions provided by either
    # functions: setting 2 points or user input values
    # for two corners by typing in the Value Content Box
    def draw_square(first, second)

      pt1, pt2 = first, second
      pt3 = [ first.x, second.y ]
      pt4 = [ second.x, first.y ]

      #draw face from 4 points and pull it back by 20
      a_face = Sketchup.active_model.active_entities.add_face(pt1, pt3, pt2, pt4)
      a_face.pushpull(-20, true)

      reset
      view.invalidate


    end # draw_square method

    # Reset values of instance variables after every
    #successful drawing of a rectangle/square
    def reset
      @pt1, @pt2 = nil
      @first_point.clear
      @second_point.clear
    end



  end # BoxMatic class


  # activate the tool ouside the BoxMatic class
  def self.activate_boxmatic
    Sketchup.active_model.select_tool(BoxMatic.new)
  end

  unless file_loaded? (__FILE__)
    menu = UI.menu('Plugins')
    menu.add_item('BoxMatic'){
      self.activate_boxmatic
    }
    file_loaded(__FILE__)
  end

end # TestPlugin module
