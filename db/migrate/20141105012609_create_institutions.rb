class CreateInstitutions < ActiveRecord::Migration
  def change
    create_table :institutions, :id => false do |t|
      t.integer :unitid, :primary => true
      t.string :instnm
      t.string :addr
      t.string :city
      t.string :stabbr
      t.string :zip
      t.integer :fips
      t.integer :obereg
      t.string :chfnm
      t.string :chftitle
      t.string :gentele
      t.string :faxtele
      t.integer :ein
      t.integer :opeid
      t.integer :opeflag
      t.string :webaddr
      t.string :adminurl
      t.string :faidurl
      t.string :applurl
      t.string :npricurl
      t.integer :sector
      t.integer :iclevel
      t.integer :control
      t.integer :hloffer
      t.integer :ugoffer
      t.integer :groffer
      t.integer :hdegofr1
      t.integer :deggrant
      t.integer :hbcu
      t.integer :hospital
      t.integer :medical
      t.integer :tribal
      t.integer :locale
      t.integer :openpubl
      t.string :act
      t.integer :newid
      t.integer :deathyr
      t.datetime :closedat
      t.integer :cyactive
      t.integer :postsec
      t.integer :pseflag
      t.integer :pset4flg
      t.integer :rptmth
      t.string :ialias
      t.integer :instcat
      t.integer :ccbasic
      t.integer :ccipug
      t.integer :ccipgrad
      t.integer :ccugprof
      t.integer :ccenrprf
      t.integer :ccsizset
      t.integer :carnegie
      t.integer :landgrnt
      t.integer :instsize
      t.integer :cbsa
      t.integer :cbsatype
      t.integer :csa
      t.integer :necta
      t.integer :f1systyp
      t.string :f1sysnam
      t.integer :f1syscod
      t.integer :countycd
      t.string :countynm
      t.integer :cngdstcd
      t.float :longitud
      t.float :latitude

      t.timestamps
    end
  end
end
