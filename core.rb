
require "sketchup.rb"

module TestPlugin
  class BoxMatic

    # BELOW ARE THE SKETCHUP CLASS METHODS

    def activate
      # Initialize InputPoint object
      @cursor = Sketchup::InputPoint.new

      # 2D point for calculating the square's dimensions
      @first_point = []
    end

    def deactivate(view)
      view.invalidate
    end

    def onCancel(reason, view)
      @first_point = []
      view.invalidate
    end

    def onMouseMove (flags, x, y, view)
      @cursor.pick(view, x, y)

      # Display cursor coordinates on status text bar
      # as mouse is hovering over the view port
      x, y = @cursor.position.to_a
      Sketchup.status_text = "#{x}, #{y}"

      view.invalidate
    end # onMouseMove method

    # Define the first and second points on click that will calculate
    # the positions of the other two points to make a rectangle
    def onLButtonDown (flags, x, y, view)
      @first_point = @cursor.position.to_a

      # Important to keep these calls in the exact order:
      # draw_floor, raise_walls, slap
      draw_floor
      raise_walls
      # slap

      view.invalidate
    end # onLButtonDown method


    def onSetCursor
      # default to 632 as custom tool image is unavailable
      UI.set_cursor(632)
    end

    # BELOW ARE THE CUSTOM METHODS

    # Draw a 4x4 square on ground plane
    # based on the dimensions calculated
    # from the position of the @first_point
    def draw_floor
      # Temporary implementation of using meters instead
      # of inches in generating models
      @meter_multiplier = 39.37
      sides = 4*@meter_multiplier

      # Define corner points 2, 3 and 4 based on the
      # coordinates of @firstpoint.
      pt1 = [ @first_point.x, @first_point.y ]
      pt2 = [ pt1.x+sides, pt1.y+sides ]
      pt3 = [ @first_point.x, pt2.y ]
      pt4 = [ pt2.x, @first_point.y ]

      # Create a 1x1 area inside the floor from the second point
      # pt2 and omit to make a porch section
      porch = [ pt2.x-1*@meter_multiplier, pt2.y-1*@meter_multiplier ]
      porch_xup = [porch.x, pt2.y]
      porch_yright = [pt2.x, porch.y]

      # Draw face from 4 points and pull it back by -20
      Sketchup.active_model.active_entities.add_face(pt1, pt3, pt2, pt4)

      # Omit the porch area from the initial rectangular floor.
      # getting the vertices first for the deletion of two unused edges
      porch_area = Sketchup.active_model.active_entities.add_face(porch, porch_xup, pt2, porch_yright)
      vertices = porch_area.vertices
      porch_area.erase!

      # Delete two edges that contain the porch area
      edge1, edge2 = vertices[0].edges
      edge1.erase!
      edge2.erase!

      # Floor area face without the porch section
      floor = vertices[2].faces.first

      # New points for the floor layout - will be
      # used to when offsetting for the outer and
      # innner walls
      @floor_layout_points = []
      floor_vertices = floor.vertices
      floor_vertices.each do |vertex|
        @floor_layout_points << vertex.position
      end

      # Push the floor 0.20 to the ground and group the
      # entities connected to the face into a group called 'floor"
      floor.pushpull(0.20*@meter_multiplier, true)
      @floor_group = Sketchup.active_model.active_entities.add_group floor.all_connected
      @floor_group.name = "floor"
    end # draw_floor method

    # Raise outer and inner walls using @floor_layout offsets
    def raise_walls
      # Defining wall attributes
      outerwall_thickness = 0.20*@meter_multiplier
      wall_space = 0.05*@meter_multiplier
      innerwall_thicness = 0.10*@meter_multiplier

      floor_layout = Sketchup.active_model.active_entities.add_face @floor_layout_points

      offset_wall(floor_layout, outerwall_thickness)

      puts "raise_walls method ended"
    end # raise_walls method

    def slap
      puts "slap method reached"


      puts "slap method ended"
      view.invalidate
    end # slap method


    # Returns a face from the vertices of the face
    # entity passed as a parameter. offval is the offset value from
    # the face edges going inside. This offset method will only work of
    # the walls are parallel with either the X or Y axis and no angular
    # dimension should be factored in.
    def offset_wall(face, offval)
      points_arr = []
      vertices = face.vertices

      # Assigning new 2D points for the inner face in relative to the
      # face that was passed as an argument
      vertices.each do |vertex|
        points = []
        edges = vertex.edges

        # Determine the x coordinate
        # print "X: #{vertex.position.x}, #{edges[0].other_vertex(vertex).position.x}"
        if vertex.position.x < edges[0].other_vertex(vertex).position.x
          points << vertex.position.x + offval
        else
          points << vertex.position.x - offval
        end

        # Determine the y coordinate
        # print "Y: #{vertex.position.y}, #{edges[1].other_vertex(vertex).position.y}"
        if vertex.position.y < edges[1].other_vertex(vertex).position.y
          points << vertex.position.y + offval
        else
          points << vertex.position.y - offval
        end

        # Adding the new XY values to the points array
        points_arr << points
      end # vertices each do iteration

      # Sketchup.active_model.active_entities.add_face points_arr

      view.invalidate
    end # offset_wallsmethod

    # Reset values of instance variables after every
    # successful drawing of a rectangle/square
    def reset
      @first_point.clear
    end
  end # BoxMatic class


  # Activate the tool ouside the BoxMatic class
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
