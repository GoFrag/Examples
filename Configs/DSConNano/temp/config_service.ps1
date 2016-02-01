configuration config
{
    Service s
    {
     	Name = "W32Time"
        State = "Running"
        StartupType = "Automatic"
        Ensure = "Present"
    }
}

config
