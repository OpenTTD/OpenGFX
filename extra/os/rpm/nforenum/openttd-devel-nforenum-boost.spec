#
# This file and all modifications and additions to the pristine
# package are under the same license as the package itself.
#

Name:           openttd-devel-nforenum-boost
Version:	1.41
Release:	1
Summary:	Boost for nforenum
Group:		Development/Libraries/C and C++
License:	Boost Software License - Version 1.0 
Url:		http://www.boost.org
Source:		boost_1_41_0.tar.bz2
Source5:  	%{name}-rpmlintrc
BuildRoot:      %{_tmppath}/%{name}-%{version}-build
#BuildArch:	noarch

%description
This package does a simple install from subdir boost
to /usr/include

%prep
%setup -n boost_1_41_0

%build
chmod 0644 README.txt

%install
mkdir -p %{buildroot}/usr/include
cp -Rp boost %{buildroot}/usr/include

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root)
%doc README.txt LICENSE_1_0.txt
%dir /usr/include/boost
/usr/include/boost/*

%changelog
* Tue Dec 15 2009 Marcel Gmür <ammler@openttdcoop.org> - 1.41
- initial spec

