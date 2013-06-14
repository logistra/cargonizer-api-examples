using System;
using System.Net;
using System.Text;
using System.IO;
using System.Reflection;

// This is a very basic C# example that does not do much error handling and may be insecure.
// Use at your own risk; improvements welcome.
namespace call_rest
{
	/// <summary>
	/// Summary description for Class1.
	/// </summary>
	class Class1
	{
		/// <summary>
		/// The main entry point for the application.
		/// </summary>
		[STAThread]
		static void Main(string[] args)
		{
			HttpWebRequest request;
			WebResponse resp;
			string targetUrl = "http://cargonizer.no/consignments";
			request = (HttpWebRequest)WebRequest.Create(targetUrl);
			Console.WriteLine("Connecting to URL: " + targetUrl);

			// read input XML from file

			StringBuilder sb = new StringBuilder();
			
			string path = Assembly.GetExecutingAssembly().Location;
			string dir = Path.GetDirectoryName(path) + "\\client.xml";
			string inputXmlQueryFilePath = dir;
			using (StreamReader inputQueryReader = new StreamReader(inputXmlQueryFilePath))
			{
				sb.Append(inputQueryReader.ReadToEnd());
			}
			Console.WriteLine("input xml value:" + sb.ToString());

			String postData = sb.ToString();
			Console.WriteLine("postData: " + postData);

				
			request.Headers.Add("X-Cargonizer-Key:ccba92e0e9e27e2cf2235ba");

			request.Headers.Add("X-Cargonizer-Sender:409");
 
			request.Method = "POST";
			request.ContentType = "application/xml";
			ASCIIEncoding ascii_encoding = new ASCIIEncoding();
			byte[] send_data = Encoding.UTF8.GetBytes(sb.ToString());

			Stream requestStream = request.GetRequestStream();
			requestStream.Write(send_data,0,send_data.Length);
			requestStream.Close();

			// get response and write to console
			resp = null;
			try 
			{	
				resp = (HttpWebResponse)request.GetResponse();   // THROWS AN EXCEPTION RIGHT HERE
			}
				
			catch(WebException exception) 
			{
				Console.WriteLine("Got a response from the Target URL, response:");

				resp = exception.Response as HttpWebResponse;					
			}
			StreamReader responseReader = new StreamReader(resp.GetResponseStream(), Encoding.UTF8);
			Console.WriteLine(responseReader.ReadToEnd());
			//TextBox1.Text = responseReader.ReadToEnd().ToString();
			resp.Close();
			
		}
	}
}
