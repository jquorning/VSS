------------------------------------------------------------------------------
--                        M A G I C   R U N T I M E                         --
--                                                                          --
--                       Copyright (C) 2021, AdaCore                        --
--                                                                          --
-- This library is free software;  you can redistribute it and/or modify it --
-- under terms of the  GNU General Public License  as published by the Free --
-- Software  Foundation;  either version 3,  or (at your  option) any later --
-- version. This library is distributed in the hope that it will be useful, --
-- but WITHOUT ANY WARRANTY;  without even the implied warranty of MERCHAN- --
-- TABILITY or FITNESS FOR A PARTICULAR PURPOSE.                            --
--                                                                          --
-- As a special exception under Section 7 of GPL version 3, you are granted --
-- additional permissions described in the GCC Runtime Library Exception,   --
-- version 3.1, as published by the Free Software Foundation.               --
--                                                                          --
-- You should have received a copy of the GNU General Public License and    --
-- a copy of the GCC Runtime Library Exception along with this program;     --
-- see the files COPYING3 and COPYING.RUNTIME respectively.  If not, see    --
-- <http://www.gnu.org/licenses/>.                                          --
--                                                                          --
------------------------------------------------------------------------------

with VSS.JSON.Documents.Arrays;
with VSS.JSON.Documents.Objects;

package VSS.JSON.Documents.Values is

   pragma Preelaborate;

   type JSON_Value_Kind is
     (No_JSON_Value,
      JSON_Array_Value,
      JSON_Object_Value,
      JSON_String_Value,
      JSON_Number,
      JSON_Boolean,
      JSON_Null);

   type JSON_Value (Kind : JSON_Value_Kind := No_JSON_Value) is record
      case Kind is
         when No_JSON_Value =>
            null;

         when JSON_Array_Value =>
            Array_Value   : VSS.JSON.Documents.Arrays.JSON_Array;

         when JSON_Object_Value =>
            Object_Value  : VSS.JSON.Documents.Objects.JSON_Object;

         when JSON_String_Value =>
            String_Value  : VSS.Strings.Virtual_String;

         when JSON_Number =>
            Number_Value  : VSS.JSON.JSON_Number;

         when JSON_Boolean =>
            Boolean_Value : Boolean;

         when JSON_Null =>
            null;
      end case;
   end record;

end VSS.JSON.Documents.Values;
