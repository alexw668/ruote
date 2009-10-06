#--
# Copyright (c) 2005-2009, John Mettraux, jmettraux@gmail.com
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#
# Made in Japan.
#++


require 'ruote/engine/context'


module Ruote

  #
  # Some methods shared by all expression storage implementations.
  #
  module StorageBase

    # Overriding #context= to make sure #observe pool is called once the
    # context is known.
    #
    def context= (c)

      @context = c
      subscribe(:expressions)
    end

    protected

    # Receiving :expressions messages
    #
    def receive (eclass, emsg, eargs)

      case emsg
      when :update
        exp = eargs[:expression]
        self[exp.fei] = exp
      when :delete
        self.delete(eargs[:fei])
      end
    end

    # Returns true if the expression matches the query.
    #
    def exp_match? (exp, query)

      return false unless exp

      if wfid = query[:wfid]
        return false unless (exp.fei.parent_wfid == wfid)
      end

      if m = query[:responding_to]
        return false unless exp.respond_to?(m)
      end
      #if m = query[:having_non_nil]
      #  return false unless exp.respond_to?(m)
      #  return false if exp.send(m) == nil
      #end
      if k = query[:class]
        return false unless exp.class == k
      end

      true
    end
  end

  #
  # A dummy implementation of the ticketing mechanism used by concurrence
  # expressions.
  # Dummy since it's intended for HashStorage and CacheStorage, both of
  # which don't require ticketing.
  #
  module DummyTickets

    class HashTicket
      def consumable?
        true
      end
      def consume
      end
    end

    def draw_ticket (fexp)

      HashTicket.new
    end

    def discard_all_tickets (fei)

      # nothing to do
    end
  end
end
