--
--  Copyright (C) 2023, AdaCore
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--

with Ada.Wide_Wide_Text_IO;

with UCD.Characters;
with UCD.Data_File_Loaders;
with UCD.Properties;

package body UCD.East_Asian_Width_Loader is

   ----------
   -- Load --
   ----------

   procedure Load (UCD_Root : Wide_Wide_String) is
      EA_Property : constant not null UCD.Properties.Property_Access :=
        UCD.Properties.Resolve ("ea");
      Value_Field  : constant Data_File_Loaders.Field_Index := 1;
      --  Index of the data field with the value of the property.

      Loader       : UCD.Data_File_Loaders.File_Loader;

   begin
      Loader.Open (UCD_Root, "EastAsianWidth.txt");

      while not Loader.End_Of_File loop
         declare
            First_Code : UCD.Code_Point;
            Last_Code  : UCD.Code_Point;

         begin
            Loader.Get_Code_Point_Range (First_Code, Last_Code);

            if Loader.Is_Missing then
               Ada.Wide_Wide_Text_IO.Put_Line
                 ("  - set to '" & Loader.Get_Field (1, True)
                  & "' in " & Loader.Get_Field (0, True));
            end if;

            declare
               Value : constant not null Properties.Property_Value_Access :=
                 UCD.Properties.Resolve
                   (EA_Property, Loader.Get_Field (Value_Field, True));

            begin
               for Code in First_Code .. Last_Code loop
                  UCD.Characters.Set (Code, EA_Property, Value);
               end loop;
            end;

            Loader.Skip_Line;
         end;
      end loop;
   end Load;

end UCD.East_Asian_Width_Loader;
