# Instructions
#   To create an event template, simply create an event with <template> in its
#     name. What's left of the event's name is the name of the template. These
#     template events will be automatically removed from the map when created.
#   You can create an event from a template event with:
#     create_event_from_template(NAME, X, Y[, SAVED])
#       NAME - the name of the template
#       X, Y - the x and y coordinates for the event, respectively
#       SAVED - whether the event should be saved (default true)

class Game_Map
  attr_accessor :saved_events
  attr_reader :template_events
  alias tdks_template_evnt_init initialize
  def initialize
    tdks_template_evnt_init
    @template_events = {}
    @saved_events = {}
  end
  
  alias tdks_template_evnt_setup setup
  def setup(map_id)
    tdks_template_evnt_setup(map_id)
    @events.each { |key, ev|
      unless ev.instance_variable_get(:@event).name.gsub!(/\<template\>/, '').nil?
        @template_events[ev.instance_variable_get(:@event).name] = ev
        @events.delete(key)
      end
    }
    @saved_events[@map_id] ||= []
    @saved_events[@map_id].each { |event|
      nind = (1..@events.keys.max+1).detect{|i|!$game_map.events.keys.include?(i)}
      @events[nind] = event
    }
  end
end

class Interpreter
  def create_event_from_template(name, x, y, save=true)
    ev = $game_map.template_events[name]
    unless ev.nil?
      ind = (1..$game_map.events.keys.max + 1).detect { |i| !$game_map.events.keys.include?(i) }
      tmp = ev.clone
      tmp.instance_variable_get(:@event).id = ind
      tmp.instance_variable_set(:@id, ind)
      tmp.moveto(x, y)
      $game_map.events[ind] = tmp
      
      if $scene.is_a?(Scene_Map)
        spriteset = $scene.instance_variable_get(:@spriteset)
        char_sprites = spriteset.instance_variable_get(:@character_sprites)
        char_sprites.push(Sprite_Character.new(spriteset.instance_variable_get(:@viewport1), tmp))
        spriteset.instance_variable_set(:@character_sprites, char_sprites)
      end
      
      if save
        $game_map.saved_events[$game_map.map_id].push(tmp)
      end
      
      $game_map.need_refresh = true
      return $game_map.events[ind]
    end
  end
end