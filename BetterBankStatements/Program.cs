using System;
using System.IO;
using System.Xml;
using System.Xml.Xsl;
using Saxon.Api;

namespace BetterBankStatements
{
    class Program
    {
        /// <summary>
        /// you shoud have xml subfolder with camt2Html.xsl and one or more iso20022 xml bank statements files
        /// app will transform all xml to BetterBankStatements.html
        /// simply edit xls file to change html result
        /// </summary>
        /// <param name="args"></param>
        static void Main(string[] args)
        {

            if (args.Length == 0)
            {
                string myPath = System.IO.Path.GetDirectoryName(System.Reflection.Assembly.GetExecutingAssembly().Location);
                string sourceFile = myPath + @"\xml\camt2Html.xsl";
                string stylesheet = myPath + @"\xml\camt2Html.xsl";
                string outputFile = myPath + @"\xml\BetterBankStatements.html";
                try
                {

                
                // Create a Processor instance.
                Processor processor = new Processor();

                // Load the source document
                DocumentBuilder builder = processor.NewDocumentBuilder();
                builder.BaseUri = new Uri(sourceFile);

                XdmNode input = builder.Build(File.OpenRead(sourceFile));

                // Create a transformer for the stylesheet.
                XsltCompiler compiler = processor.NewXsltCompiler();
                compiler.BaseUri = new Uri(stylesheet);
                Xslt30Transformer transformer = compiler.Compile(File.OpenRead(stylesheet)).Load30();

                // Set the root node of the source document to be the global context item
                transformer.GlobalContextItem = input;

                // Create a serializer, with output to the standard output stream
                Serializer serializer = processor.NewSerializer();
                serializer.SetOutputStream(new FileStream(outputFile, FileMode.Create, FileAccess.Write));

                // Transform the source XML and serialize the result to the output file.
                transformer.ApplyTemplates(input, serializer);

                Console.WriteLine("\nOutput written to " + outputFile + "\n");
                }
                catch (Exception ex)
                {
                    Console.WriteLine("\nError:" + ex.Message + "\n");
                    Console.WriteLine(ex.StackTrace + "\n");
                }
            }
            else {
                Console.WriteLine("izpiski (xml iso20022) morajo bit v podmapi xml skupaj z camt2Html.xsl");
                Console.WriteLine("retultat bo izpiski.html");
            }
            Console.ReadKey();
        }

    }
}
