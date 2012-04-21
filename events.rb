
class Events

	def initialize
		@listeners = {}
	end

	def listen event, *f, &p
		if p
		  (@listeners[event] ||= []) << p
		else
		  (@listeners[event] ||= []) << f[0]
		end

		return @listeners.length
	end

  def check_result r
    (r == :unbind)
  end

	def invoke event, *param
    return false unless @listeners.has_key? event
		@listeners[event].each_with_index do |e, i| 
      res = e.call(*param) if e
      @listeners[event][i]=nil if check_result res
    end
	end

  def compact # fucks up ids
    @listeners.each.to_a.delete_if {|f| f==nil}
  end

	def nullify event, id
		return unless @listeners.has_key? event
		return unless @listeners[events].length >= id

		@listeners[event][id] = nil
	end

end
