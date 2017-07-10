module BlocRecord
  class Collection < Array

    def update_all(updates)
      ids = self.map(&:id)
      self.any? ? self.first.class.update(ids, updates) : false
    end

    def destroy_all
      for obj in self
        obj.destroy
      end
    end

  end
end
