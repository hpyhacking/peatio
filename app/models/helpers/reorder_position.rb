# frozen_string_literal: true

module Helpers
  module ReorderPosition

    # Function which insert object inside existing list
    def insert_position(model)
      # Get current currency amount
      count = model.class.count

      # If position value greater than currency amount
      # System should add this object in the end of the list
      # For example:
      # List size eq to 15 and user want to set position to 24, system will set it on 16 position
      if model.position > count
        # Use update_column in favor of update to skip callback methods
        model.update_column(:position, count)
      elsif model.position == count
        # System shouldn't reorder objects if new object has last position in the list
        return
      else
        # As soon as create doesnt have old position value
        # System will move the list up to the highest position(count)
        # So techically old position == highest_position = count
        highest_position = count
        # Current model position
        new_position = model.position

        shuffle_positions_on_intermediate_items(model, highest_position, new_position)
      end
    end

    # Function which update object inside existing list
    def update_position(model)
      # Get current currency amount
      count = model.class.count

      # Previous model position
      old_position = model.position_was
      # If new position value greater than currency amount
      # System should add this object in the end of the list
      new_position = model.position > count ? count : model.position

      shuffle_positions_on_intermediate_items(model, old_position, new_position)
    end

    private

    def shuffle_positions_on_intermediate_items(model, old_position, new_position)
      # https://apidock.com/rails/String/tableize
      # Currency => currencies   Market => markets
      table_name = model.class.name.tableize

      # Define SQL query for reordering positions
      sql = if old_position > new_position
              increment_positions_on_lower_items(model.id, table_name, old_position, new_position)
            else
              decrement_positions_on_higher_items(model.id, table_name, old_position, new_position)
            end

      ActiveRecord::Base.transaction do
        # Use update_column in favor of update to skip callback methods
        # Set position as 0 before reordering
        # Top list position starts from 1, so 0 is safe place for those updating
        model.update_column(:position, 0)
        # Reorder ojects in the list
        ActiveRecord::Base.connection.execute(sql)
        # Update object with desired position
        model.update_column(:position, new_position)
      end
    end

    # Updates objects positions between old position and new position
    # If old position > new position
    def increment_positions_on_lower_items(model_id, table_name, old_position, new_position)
      "UPDATE #{table_name} SET position = (#{table_name}.position + 1) "\
      "WHERE (#{table_name}.id != '#{model_id}') "\
      "AND (#{table_name}.position >= #{new_position}) "\
      "AND (#{table_name}.position < #{old_position})"
    end

    # Updates objects positions between old position and new position
    # If old position < new position
    def decrement_positions_on_higher_items(model_id, table_name, old_position, new_position)
      "UPDATE #{table_name} SET position = (#{table_name}.position - 1) "\
      "WHERE (#{table_name}.id != '#{model_id}') "\
      "AND (#{table_name}.position > #{old_position}) "\
      "AND (#{table_name}.position <= #{new_position})"
    end
  end
end
