<?php
require_once('../wp-load.php');
require_once('../wp-admin/includes/admin.php');
require_once('../wp-admin/includes/plugin.php');

switch ($_GET["type"]){
    case 'plugin':
        $plugin = new plugin();
        
        $plugin->state = $_GET['state'];
        $plugin->name = $_GET['name'];
        
        switch ($_GET['method'])
        {
            case 'test':
                if($plugin->test())
                {
                    echo "True";    
                }
                else
                {
                    echo "False";
                }
                continue;
            case 'set':
                $plugin->set();
                echo "Successfully configured plugin " . $plugin->name . ".";
                continue;
            case 'get':
                $plugins = $plugin->get();
                
                echo '{"plugins": [';
                
                $i = 0;
                foreach ($plugins as $plugin)
                {
                    if($i > 0)
                    {
                        echo ",";
                    }
                    $i = $i + 1;
                    echo '{"id": ' .  $plugin . "}"; 
                }

                echo '] }';
                
                continue;
        }
        
        $plugin = null;
        break;
    case 'theme':
        $theme = new theme();
        
        $theme->template = $_GET['template'];
        
        switch ($_GET['method']){
            case 'test':
                if($theme->test()){
                    echo "True";    
                }else{
                    echo "False";
                }
                continue;
            case 'set':
                $theme->set();
                echo "Successfully set theme to " . $theme->template . ".";
                continue;
            case 'get':
                echo $theme->get();
                continue;
        }
        
        $theme = null;
        break;
}

class plugin
{
    public $state;
    public $name;
    
    public function set()
     {
        //$path = 'wordpress-importer/wordpress-importer.php';
        $path = $this->name . '/' . $this->name . '.php';
        
        $current_plugins = get_option('active_plugins');
    
        if(!$this->test())
        {
            if($this->state == 'enabled')
            {
                array_push($current_plugins, $path);
            }
            else // state == 'disabled'
            {
                $temp_array = array();
                foreach ($current_plugins as $current_plugin)
                {
                	if ($current_plugin != $path)
                    {
                    	array_push($temp_array,$current_plugin);
                    }
                    
                }
                
                $current_plugins = $temp_array;
            }
            
            try
            {
                update_option('active_plugins', $current_plugins);
            }
            catch (Exception $exception)
            {
        	    throw new Exception('Failed to set the plugin to ' . $this->name . '.', $exception.code);
            }
        }
     }
     
    public function test()
    {
        $path = $this->name . '/' . $this->name . '.php';
        
        $current_plugins = get_option('active_plugins');
        
        if((in_array($path, $current_plugins) && ($this->state == 'enabled')) || (!in_array($path, $current_plugins) && ($this->state == 'disabled')))
        {
            return true;
        }
        else
        {
            return false;
        }
    }
    
    public function get()
    {
        $current_plugins = get_option('active_plugins');
        $plugin_array = array();
        
        foreach ($current_plugins as $plugin)
        {
            array_push($plugin_array, $plugin);
        }
        
        return $plugin_array;
    }
    
}

class theme
{
    public $template;
    
    public function set()
    {
        try
        {
            update_option('template', $this->template);
            update_option('stylesheet', $this->template);
            update_option('current_theme', $this->template);
        }
        catch (Exception $exception)
        {
        	throw new Exception('Failed to set the theme to ' . $this->template . '.', $exception.code);
        }
        
    }
    
    public function test()
    {
        if($this->get() == $this->template)
        {
            return true;
        }
        else
        {
            return false;
        }
    }
    
    public function get()
    {
        return get_template();
    }
    
}
 
?>