Filename: noHWsp / generalize.bat ---------------------------------------------
 *
 * Author: Petr Rosicky <rosicky.petr@cz.ibm.com>
 *
 * (C) Copyright 2020 IBM Corporation
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of the
 * License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * General Public License for more details.
 *          
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software Foundation,
 * Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA

* Purpose ---------------------------------------------------------------------
Running generalize.bat will initiate Windows Hardware Installation process during next boot.
Sysprep is instructed by provided special unatt.xml file to perform HW specialize part ONLY.
System shutdown will be initiated once setup completed.

Sysprep should preserve all accounts and groups setup, computer SID, so as all unique IDs for any Microsoft software installed (wusa, sccm, ...).
This utility has been created by IBM to allow HW migrations of Windows systems using the original MS Windows95-based kernel, 
so any up to Windows 2008 (nonR2) and 2012 (nonR2).

* DISCLAIMER !!! --------------------------------------------------------------
Using sysprep this way is not prohibited by Microsoft company. 
But it is also not officially supported!

Author is providing it "AS IT IS", without any warraty, just with the intention to possibly help others to allow them 
to perform HW migrations by using native MS technologies.


