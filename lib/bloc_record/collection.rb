module BlocRecord
  class Collection < Array

    def update_all(updates)
      ids = self.map(&:id)
      self.any? ? self.first.class.update(ids, updates) : false
    end

    def where(args)
      multi_wheres = []
      for key in args.keys
        multi_wheres += self.class.update(self.id, { attribute => value })
      end
      multi_wheres
    end

    def take(num=1)
      self[0..num-1]
    end

  end
end
