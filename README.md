#DreamSIS
DreamSIS is a tool for managing your mentoring outreach program. Originally built by the University of Washington for use by the Dream Project, a college-access mentoring organization, DreamSIS is now available to any organization interested in using it for program management.

##Global Setup
All config options are stored in the `Customer` record; there are no other global configurations. API keys for connected services should be specified in `config/api-keys.yml`. There is a sample file layout in `config/api-keys.example.yml`.

##Multitenant Setup
DreamSIS uses the [Apartment](https://github.com/influitive/apartment) to manage multitenancy. However, automated tenant creation is not yet built in. To create a new tenant in production:

1. Choose a unique tenant name, which will be the subdomain for that tenant.
2. Create a MySQL database with that name.
3. Grant permissions on that database to your production database user.
4. Create a new AWS bucket, based on the default bucket name specified in `config/api-keys.yml` with a hyphen and the tenant name concetenated. So if your default bucket name is "my-usercontent", create a bucket called "my-usercontent-{tenant_name}".
5. Finally, create a new `Customer` record with the tenant name set as the `url_shortcut`. After creation, the tenant database will be initialized with the latest `db/schema.rb` and is ready to use.

##License

Copyright &copy; 2006&ndash;2015, University of Washington
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
* Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
* The name of the author may not be used to endorse or promote products derived from this software without specific prior written permission.


THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.