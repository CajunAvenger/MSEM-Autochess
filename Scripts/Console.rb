

#==============================================================================
# ** Console Support for XP/VX
#------------------------------------------------------------------------------
# By Grim from http://www.biloucorp.com
#==============================================================================
# Function :
#==============================================================================
# Console.log(text)  => display text in console
# console.log(text)  => display text in console
#==============================================================================
# ** Configuration
#------------------------------------------------------------------------------
# Configuration data
#==============================================================================
module Configuration
    #--------------------------------------------------------------------------
    # * Active Console (true=>activate console, false=>unactivate console)
    # * Only for XP and VX
    #--------------------------------------------------------------------------
    ENABLE_CONSOLE = true
end
#==============================================================================
# ** Util
#------------------------------------------------------------------------------
# Usefull tools
#==============================================================================
module Util
    #--------------------------------------------------------------------------
    # * Singleton
    #--------------------------------------------------------------------------
    extend self
    #--------------------------------------------------------------------------
    # * if RPG MAKER XP
    #--------------------------------------------------------------------------
    def rpg_maker_xp?  
        defined?(Hangup)
    end
    #--------------------------------------------------------------------------
    # * if RPG MAKER VX
    #--------------------------------------------------------------------------
    def rpg_maker_vx?  
        !rpg_maker_xp? && (RUBY_VERSION == '1.8.1')
    end
    #--------------------------------------------------------------------------
    # * if RPG MAKER VXAce
    #--------------------------------------------------------------------------
    def rpg_maker_vxace?  
        RUBY_VERSION == '1.9.2'
    end
    #--------------------------------------------------------------------------
    # * alias
    #--------------------------------------------------------------------------
    alias :rmxp?    :rpg_maker_xp?
    alias :rmvx?    :rpg_maker_vx?
    alias :rmvxace? :rpg_maker_vxace?
    #--------------------------------------------------------------------------
    # * Get Screen Object
    #--------------------------------------------------------------------------
    def get_screen  
        return $game_map.screen if rpg_maker_vxace?  
        $game_screen
    end
    #--------------------------------------------------------------------------
    # * Debug mode
    #--------------------------------------------------------------------------
    def from_editor?  
        $TEST || $DEBUG
    end
    #--------------------------------------------------------------------------
    # * Get current Scene
    #--------------------------------------------------------------------------
    def scene  
        return SceneManager.scene if rpg_maker_vxace?  
        $scene
    end
    #--------------------------------------------------------------------------
    # * Window Handle
    #--------------------------------------------------------------------------
    def handle  
        Win32API::FindWindowA.call('RGSS Player', 0)
    end
end
#==============================================================================
# ** Win32API
#------------------------------------------------------------------------------
#  win32/registry is registry accessor library for Win32 platform.
#  It uses dl/import to call Win32 Registry APIs.
#==============================================================================
class Win32API
    #--------------------------------------------------------------------------
    # * Librairy
    #--------------------------------------------------------------------------
    AllocConsole        = self.new('kernel32', 'AllocConsole', 'v', 'l')
    FindWindowA         = self.new('user32', 'FindWindowA', 'pp', 'i')
    SetForegroundWindow = self.new('user32', 'SetForegroundWindow','l','l')
    SetConsoleTitleA    = self.new('kernel32','SetConsoleTitleA','p','s')
    WriteConsoleOutput  = self.new('kernel32', 'WriteConsoleOutput', 'lpllp', 'l' )
end
#==============================================================================
# ** Console
#------------------------------------------------------------------------------
#  VXAce Console Handling
#==============================================================================
module Console
    #--------------------------------------------------------------------------
    # * Singleton
    #--------------------------------------------------------------------------
    extend self
    #--------------------------------------------------------------------------
    # * Initialize
    #--------------------------------------------------------------------------
    def init  
        unless Util.rmvxace?    
        return unless Util.from_editor?    
        Win32API::AllocConsole.call    
        Win32API::SetForegroundWindow.call(Util.handle)    
        Win32API::SetConsoleTitleA.call("RGSS Console")    
        $stdout.reopen('CONOUT$')  
    end
end
#--------------------------------------------------------------------------
# * Log
#--------------------------------------------------------------------------
def log(*data)  
    return unless Util.from_editor?  
    if Util.rmvxace?    
        p(*data)    
        return  
    end  
    return unless Configuration::ENABLE_CONSOLE  
    puts(*data.collect{|d|d.inspect})
    end
end
#==============================================================================
# ** Kernel
#------------------------------------------------------------------------------
#  Object class methods are defined in this module.
#  This ensures compatibility with top-level method redefinition.
#==============================================================================
module Kernel
    #--------------------------------------------------------------------------
    # * Alias for console
    #--------------------------------------------------------------------------
    def console;
        Console;
    end
    #--------------------------------------------------------------------------
    # * pretty print
    #--------------------------------------------------------------------------
    if !Util.rmvxace? && Util.from_editor?  
        def p(*args)    
            console.log(*args)  
        end
    end
end
#--------------------------------------------------------------------------
# * Initialize Console
#--------------------------------------------------------------------------
Console.init if Configuration::ENABLE_CONSOLE
