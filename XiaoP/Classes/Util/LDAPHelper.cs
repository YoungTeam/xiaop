using System;
using System.Collections.Generic;
using System.Text;
using System.DirectoryServices;

namespace XiaoP.Classes.Util
{
    class LDAPHelper
    {
        private static string LDAP_DOMAIN = "yt-inc.com";
        private static string LDAP_SERVER = "ldap.yt-inc.com";
        private static string LDAP_STRING = "USER-NAME@yt-inc.com";

        private string ldapUrl = LDAP_SERVER;
        private string ldapUser = LDAP_STRING;
        private string ldapPwd = "";

        public LDAPHelper(string ldap_url, string ldap_user, string ldap_pwd)
        {

            if (ldap_url != null)
                this.ldapUrl = ldap_url;
            if (ldap_user != null)
            {
                if (ldap_user.IndexOf(LDAP_DOMAIN) != -1)
                    this.ldapUser = LDAP_STRING.Replace("USER-NAME", ldap_user.Replace("@" + LDAP_DOMAIN, ""));
                else
                    this.ldapUser = ldap_user + "@" + LDAP_DOMAIN;
            } if (ldap_pwd != null)
                this.ldapPwd = ldap_pwd;

        }

        public LDAPHelper(string ldap_user, string ldap_pwd)
        {

            new LDAPHelper(ldap_user, ldap_pwd);

        }

        public bool login()
        {

            DirectoryEntry entry = null;
            bool succ = false;
            try
            {
                entry = new DirectoryEntry("LDAP://" + this.ldapUrl, this.ldapUser, this.ldapPwd, AuthenticationTypes.None);

                object native = entry.NativeObject;

                entry.Close();
                entry = null;

                succ = true;

            }
            catch (System.Exception ex)
            {
                Console.Write(ex.Message);
                //throw new Exception("Error authenticating user." + ex.Message);

            }
            return succ;
        }



    }
}
