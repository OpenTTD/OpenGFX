
Name:           %{dz_repo}
Version:        %{dz_version}
Release:        %{_vendor}%{?suse_version}
Summary:        DevZone Projects Compiler

Group:          Amusements/Games
License:        GPLv2
URL:            http://dev.openttdcoop.org

Source0:        %{name}-%{version}.tar

BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-buildroot

BuildArch:      noarch

BuildRequires:  mercurial p7zip xz grfcodec unix2dos grf2html gimp openttd %{dz_requires}

%description
Build script for #openttdcoop DevZone projects

%prep
%setup -qn %{name}
cd ..
mv %{name} %{name}.hg
mkdir %{name}
cd %{name}.hg

# update to the tag, if not revision
[ "$(echo %{version} | cut -b-1)" != "r" ] && hg up %{version}

make maintainer-clean

make %{?_smp_mflags} 1>../%{name}/%{name}-%{version}-build.log 2>../%{name}/%{name}-%{version}-build.err.log
make %{?_smp_mflags} bundle_xsrc 1>>../%{name}/%{name}-%{version}-build.log 2>>../%{name}/%{name}-%{version}-build.err.log
make %{?_smp_mflags} bundle_gsrc 1>>../%{name}/%{name}-%{version}-build.log 2>>../%{name}/%{name}-%{version}-build.err.log
make %{?_smp_mflags} bundle_zip ZIP="7za a" ZIP_FLAGS="-tzip -mx9" 1>>../%{name}/%{name}-%{version}-build.log 2>>../%{name}/%{name}-%{version}-build.err.log
make %{?_smp_mflags} bundle_ttdp ZIP="7za a" ZIP_FLAGS="-tzip -mx9" 1>>../%{name}/%{name}-%{version}-build.log 2>>../%{name}/%{name}-%{version}-build.err.log

hg st 1>> ../%{name}/%{name}-%{version}-build.err.log 2>>../%{name}/%{name}-%{version}-build.err.log
[[ $(hg st -m) ]] && exit

mv *.tar.gz *.tar.xz *.zip ../%{name} 1>>../%{name}/%{name}-%{version}-build.log 2>>../%{name}/%{name}-%{version}-build.err.log
cd ../%{name} 1>>../%{name}/%{name}-%{version}-build.log 2>>../%{name}/%{name}-%{version}-build.err.log
tar -xJ < `ls *-source.tar.xz` 1>>%{name}-%{version}-build.log 2>>%{name}-%{version}-build.err.log
mv *-source/* . 1>>%{name}-%{version}-build.log 2>>%{name}-%{version}-build.err.log
rmdir *-source 1>>%{name}-%{version}-build.log 2>>%{name}-%{version}-build.err.log
# move ttdpatch pack and generate md5file:
mkdir ttdpatch 1>>%{name}-%{version}-build.log 2>>%{name}-%{version}-build.err.log
mv opengfx-ttdpatch* ttdpatch/ 1>>%{name}-%{version}-build.log 2>>%{name}-%{version}-build.err.log
FILENAME=`basename ttdpatch/*` 1>>%{name}-%{version}-build.log 2>>%{name}-%{version}-build.err.log
echo $(cd ttdpatch && md5sum $FILENAME) > ttdpatch/$FILENAME.md5 2>>%{name}-%{version}-build.err.log
cp ../%{name}.hg/docs/ttdpatch.txt ttdpatch/ 1>>%{name}-%{version}-build.log 2>>%{name}-%{version}-build.err.log

%build
#we have unix2dos installed for the zip, but now, we like to build without
#docs aren't built by default
make %{?_smp_mflags} docs UNIX2DOS= 1>>%{name}-%{version}-build.log 2>>%{name}-%{version}-build.err.log
grf2html -o grf2html *.grf 1>%{name}-%{version}-grf2html.log 2>&1

# cleanup error log
mv %{name}-%{version}-build.err.log error.log
cat error.log |  grep -v "LibGimpBase-WARNING" | grep -v "Gtk-WARNING" | grep -v "GLib-WARNING" | grep -v "^$" >%{name}-%{version}-build.err.log || :

%install
rpm -qa | sort > rpmlist
make install INSTALL_DIR=%{buildroot}%{_datadir}/openttd/data/opengfx-%{version}

%check
make check

mkdir -p $HOME/.openttd/data
ln -sfT %{buildroot}%{_datadir}/openttd/data/opengfx-%{version} $HOME/.openttd/data/opengfx
openttd -vnull:ticks=1 -d9 1>%{name}-%{version}-openttd.log 2>&1

%clean
#rm -rf %{buildroot}

%files
%defattr(-,root,root,-)
%dir %{_datadir}/openttd
%dir %{_datadir}/openttd/data
%doc %{_datadir}/openttd/data/changelog.txt
%doc %{_datadir}/openttd/data/license.txt
%{_datadir}/openttd/data/ogfx1_base.grf
%{_datadir}/openttd/data/ogfxc_arctic.grf
%{_datadir}/openttd/data/ogfxe_extra.grf
%{_datadir}/openttd/data/ogfxh_tropical.grf
%{_datadir}/openttd/data/ogfxi_logos.grf
%{_datadir}/openttd/data/ogfxt_toyland.grf
%{_datadir}/openttd/data/opengfx.obg
%doc %{_datadir}/openttd/data/readme.txt

%changelog
