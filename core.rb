
require "sketchup.rb"

module TestPlugin
  class BoxMatic

    # BELOW ARE THE SKETCHUP CLASS METHODS

    # this will be called once the tool is
    # activated/clicked by the user
    def activate

      # Initialize InputPoint object
      @cursor = Sketchup::InputPoint.new

      # two 2D points for calculating the square's dimensions
      @first_point = []

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
      view.invalidate
    end

    def onMouseMove (flags, x, y, view)

      @cursor.pick(view, x, y)

      # display cursor coordinates on status text bar
      # as mouse is hovering over the view port
      x, y = @cursor.position.to_a
      Sketchup.status_text = "#{x}, #{y}"

      view.invalidate
    end # onMouseMove method

    # Define the first and second points on click that will calculate
    # the positions of the other two points to make a rectangle
    def onLButtonDown (flags, x, y, view)

      @first_point = @cursor.position.to_a
      draw_floor

      view.invalidate
    end # onLButtonDown method

    # define cursor style when tool is activated
    CURSOR = 632
    def onSetCursor
      UI.set_cursor(CURSOR)
    end

    def enableVCB?
      return true
    end

    # BELOW ARE THE CUSTOM METHODS

    # Draw a square on ground plane
    # based on the dimensions provided by either
    # functions: setting 2 points or user input values
    # for two corners by typing in the Value Content Box
    def draw_floor

      # temporary implementation of using meters instead
      # of inches in generating models
      meter_multiplier = 39.37
      sides = 4*meter_multiplier

      # Define points 2, 3 and 4 based on the coordinates
      # of @firstpoint.
      pt1 = [ @first_point.x, @first_point.y ]
      pt2 = [ pt1.x+sides, pt1.y+sides ]
      pt3 = [ @first_point.x, pt2.y ]
      pt4 = [ pt2.x, @first_point.y ]

      # create a 1x1 area inside the floor from the second point
      # pt2 and omit to make a porch section
      porch = [ pt2.x-1*meter_multiplier, pt2.y-1*meter_multiplier ]
      porch_xup = [porch.x, pt2.y]
      porch_yright = [pt2.x, porch.y]

      # draw face from 4 points and pull it back by -20
      rectangle = Sketchup.active_model.active_entities.add_face(pt1, pt3, pt2, pt4)
      vertices = rectangle.vertices

      # omit the porch area from the initial rectangular floor
      @porch_area = Sketchup.active_model.active_entities.add_face(porch, porch_xup, pt2, porch_yright)
      @porch_area.erase!

      # floor area without the porch section
      vertex1 = vertices[0]
      @floor_area = vertices[0].faces.first

      @floor_area.pushpull(-2*meter_multiplier, true)

      reset
      view.invalidate

    end # draw_floor method

    # Reset values of instance variables after every
    #successful drawing of a rectangle/square
    def reset
      @first_point.clear
    end

    def genererate_wall(group)

    end

    def generate_door

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
