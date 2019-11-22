using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore;
using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;

namespace src
{
    
    public class Busy
    {
        
        public void StayBusy()
        {
            while (true)
            {   
                for (var i = 1; i < 1000000; i++){
                    
                }
            }
        }
    }

    public class Program
    {
        
        public static void Main(string[] args)
        {
            var b = new Busy();
            b.StayBusy();

            Console.WriteLine("Hello! I am the dotnet API! V1");
            BuildWebHost(args).Run();
        }

        public static IWebHost BuildWebHost(string[] args) =>
            WebHost.CreateDefaultBuilder(args)
                .UseStartup<Startup>()
                .UseUrls("http://*:5000")
                .Build();
    }
}
