using Microsoft.Owin;
using Owin;

[assembly: OwinStartupAttribute(typeof(EpicCalc.Startup))]
namespace EpicCalc
{
    public partial class Startup
    {
        public void Configuration(IAppBuilder app)
        {
            ConfigureAuth(app);
        }
    }
}
