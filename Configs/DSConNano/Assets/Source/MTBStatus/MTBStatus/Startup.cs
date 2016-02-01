using Microsoft.Owin;
using Owin;

[assembly: OwinStartupAttribute(typeof(MTBStatus.Startup))]
namespace MTBStatus
{
    public partial class Startup {
        public void Configuration(IAppBuilder app) {
            ConfigureAuth(app);
        }
    }
}
