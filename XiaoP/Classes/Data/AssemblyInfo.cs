using System;
using System.Collections.Generic;
using System.Text;
using System.Reflection;
using XiaoP.Wnds;

namespace XiaoP.Classes.Data
{
    public class AssemblyInfo
    {

        //Used by functions to access information from Assembly Attributes
        /// <summary>
        /// myType.
        /// </summary>
        private Type myType;
        /// <summary>
        /// Initializes a new instance of the <see cref="AssemblyInfo"/> class.
        /// </summary>
        public AssemblyInfo()
        {
            //Shellform here denotes the actual form.
            myType = typeof(MainWnd);
        }
        /// <summary>
        /// Gets the name of the assembly.
        /// </summary>
        /// <value>The name of the assembly.</value>
        public String AssemblyName
        {
            get
            {
                return myType.Assembly.GetName().Name.ToString();
            }
        }
        /// <summary>
        /// Gets the full name of the assembly.
        /// </summary>
        /// <value>The full name of the assembly.</value>
        public String AssemblyFullName
        {
            get
            {
                return myType.Assembly.GetName().FullName.ToString();
            }
        }
        /// <summary>
        /// Gets the code base.
        /// </summary>
        /// <value>The code base.</value>
        public String CodeBase
        {
            get
            {
                return myType.Assembly.CodeBase;
            }
        }
        /// <summary>
        /// Gets the copyright.
        /// </summary>
        /// <value>The copyright.</value>
        public String Copyright
        {
            get
            {
                Type att = typeof(AssemblyCopyrightAttribute);
                object[] r = myType.Assembly.GetCustomAttributes(att, false);
                AssemblyCopyrightAttribute copyattr = (AssemblyCopyrightAttribute)r[0];
                return copyattr.Copyright;
            }
        }
        /// <summary>
        /// Gets the company.
        /// </summary>
        /// <value>The company.</value>
        public String Company
        {
            get
            {
                Type att = typeof(AssemblyCompanyAttribute);
                object[] r = myType.Assembly.GetCustomAttributes(att, false);
                AssemblyCompanyAttribute compattr = (AssemblyCompanyAttribute)r[0];
                return compattr.Company;
            }
        }
        /// <summary>
        /// Gets the description.
        /// </summary>
        /// <value>The description.</value>
        public String Description
        {
            get
            {
                Type att = typeof(AssemblyDescriptionAttribute);
                object[] r = myType.Assembly.GetCustomAttributes(att, false);
                AssemblyDescriptionAttribute descattr = (AssemblyDescriptionAttribute)r[0];
                return descattr.Description;
            }
        }
        /// <summary>
        /// Gets the product.
        /// </summary>
        /// <value>The product.</value>
        public String Product
        {
            get
            {
                Type att = typeof(AssemblyProductAttribute);
                object[] r = myType.Assembly.GetCustomAttributes(att, false);
                AssemblyProductAttribute prodattr = (AssemblyProductAttribute)r[0];
                return prodattr.Product;
            }
        }
        /// <summary>
        /// Gets the title.
        /// </summary>
        /// <value>The title.</value>
        public String Title
        {
            get
            {
                Type att = typeof(AssemblyTitleAttribute);
                object[] r = myType.Assembly.GetCustomAttributes(att, false);
                AssemblyTitleAttribute titleattr = (AssemblyTitleAttribute)r[0];
                return titleattr.Title;
            }
        }
        /// <summary>
        /// Gets the version.
        /// </summary>
        /// <value>The version.</value>
        public String Version
        {
            get
            {
                return myType.Assembly.GetName().Version.ToString();
            }
        }



    }
}
