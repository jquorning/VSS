------------------------------------------------------------------------------
--                        M A G I C   R U N T I M E                         --
--                                                                          --
--                       Copyright (C) 2020, AdaCore                        --
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

with VSS.Strings.Conversions;
with VSS.Implementation.UTF8_Encoding;
with VSS.Unicode;

package body VSS.Text_Streams.Memory is

   use type Ada.Streams.Stream_Element_Offset;

   -------------------
   -- Error_Message --
   -------------------

   overriding function Error_Message
     (Self : Memory_UTF8_Input_Stream) return VSS.Strings.Virtual_String is
   begin
      return Self.Diagnosis;
   end Error_Message;

   ---------
   -- Get --
   ---------

   overriding procedure Get
     (Self    : in out Memory_UTF8_Input_Stream;
      Item    : out VSS.Characters.Virtual_Character;
      Success : in out Boolean)
   is
      use type VSS.Unicode.Code_Point;

      procedure Report_Error (Message : String);

      ------------------
      -- Report_Error --
      ------------------

      procedure Report_Error (Message : String) is
      begin
         Success := False;
         Item    := VSS.Characters.Virtual_Character'Val (0);

         Self.Diagnosis := VSS.Strings.Conversions.To_Virtual_String (Message);
      end Report_Error;

      U1 : VSS.Unicode.Code_Point;
      U2 : VSS.Unicode.Code_Point;
      U3 : VSS.Unicode.Code_Point;
      U4 : VSS.Unicode.Code_Point;

   begin
      if Self.Current > Self.Buffer.Length then
         Success := False;
         Item := VSS.Characters.Virtual_Character'Val (0);

         return;
      end if;

      case Self.Buffer.Element (Self.Current) is
         when 16#00# .. 16#7F# =>
            --  1x code units sequence
            --
            --  00 .. 7F

            Item :=
              VSS.Characters.Virtual_Character'Val
                (Self.Buffer.Element (Self.Current));
            Self.Current := Self.Current + 1;

         when 16#C2# .. 16#DF# =>
            --  2x code units sequence
            --
            --  C2 .. DF | 80 .. BF

            if Self.Current + 1 > Self.Buffer.Length then
               raise Program_Error;
            end if;

            U1 :=
              VSS.Unicode.Code_Point (Self.Buffer.Element (Self.Current));
            U2 :=
              VSS.Unicode.Code_Point (Self.Buffer.Element (Self.Current + 1));

            if U2 not in 16#80# .. 16#BF# then
               raise Program_Error;
            end if;

            U1 := (U1 and 2#0001_1111#) * 2#0100_0000#;
            U2 := U2 and 2#0011_1111#;

            Item := VSS.Characters.Virtual_Character'Val (U1 or U2);
            Self.Current := Self.Current + 2;

         when 16#E0# .. 16#EF# =>
            --  3x code units sequence
            --
            --  E0       | A0 .. BF | 80 .. BF
            --  E1 .. EC | 80 .. BF | 80 .. BF
            --  ED       | 80 .. 9F | 80 .. BF
            --  EE .. EF | 80 .. BF | 80 .. BF

            if Self.Current + 2 > Self.Buffer.Length then
               Report_Error ("incomplete three code unit sequence");

               return;
            end if;

            U1 :=
              VSS.Unicode.Code_Point (Self.Buffer.Element (Self.Current));
            U2 :=
              VSS.Unicode.Code_Point (Self.Buffer.Element (Self.Current + 1));
            U3 :=
              VSS.Unicode.Code_Point (Self.Buffer.Element (Self.Current + 2));

            if U1 = 16#E0# and U2 not in 16#A0# .. 16#BF# then
               Report_Error
                 ("invalid UTF-8 sequence (wrong second code unit of three"
                     & " code units sequene)");

               return;

            elsif U1 in 16#E1# .. 16#EC# and U2 not in 16#80# .. 16#BF# then
               Report_Error
                 ("invalid UTF-8 sequence (wrong second code unit of three"
                     & " code units sequene)");

               return;

            elsif U1 = 16#ED# and U2 not in 16#80# .. 16#9F# then
               Report_Error
                 ("invalid UTF-8 sequence (wrong second code unit of three"
                     & " code units sequene)");

               return;

            elsif U1 in 16#EE# .. 16#EF# and U2 not in 16#80# .. 16#BF# then
               raise Program_Error;
            end if;

            if U3 not in 16#80# .. 16#BF# then
               raise Program_Error;
            end if;

            U1 := (U1 and 2#0000_1111#) * 2#01_0000_0000_0000#;
            U2 := (U2 and 2#0011_1111#) * 2#0100_0000#;
            U3 := U3 and 2#0011_1111#;

            Item := VSS.Characters.Virtual_Character'Val (U1 or U2 or U3);
            Self.Current := Self.Current + 3;

         when 16#F0# .. 16#F4# =>
            --  4x code units sequence
            --
            --  F0       | 90 .. BF | 80 .. BF | 80 .. BF
            --  F1 .. F3 | 80 .. BF | 80 .. BF | 80 .. BF
            --  F4       | 80 .. 8F | 80 .. BF | 80 .. BF

            if Self.Current + 3 > Self.Buffer.Length then
               raise Program_Error;
            end if;

            U1 :=
              VSS.Unicode.Code_Point (Self.Buffer.Element (Self.Current));
            U2 :=
              VSS.Unicode.Code_Point (Self.Buffer.Element (Self.Current + 1));
            U3 :=
              VSS.Unicode.Code_Point (Self.Buffer.Element (Self.Current + 2));
            U4 :=
              VSS.Unicode.Code_Point (Self.Buffer.Element (Self.Current + 3));

            if U1 = 16#F0# and U2 not in 16#90# .. 16#BF# then
               raise Program_Error;

            elsif U1 in 16#F1# .. 16#F3# and U2 not in 16#80# .. 16#BF# then
               raise Program_Error;

            elsif U1 = 16#F4# and U2 not in 16#80# .. 16#8F# then
               Report_Error
                 ("invalid UTF-8 sequence (wrong second code unit of four"
                     & " code units sequene)");

               return;
            end if;

            if U3 not in 16#80# .. 16#BF# then
               raise Program_Error;
            end if;

            if U4 not in 16#80# .. 16#BF# then
               raise Program_Error;
            end if;

            U1 := (U1 and 2#0000_0111#) * 2#0100_0000_0000_0000_0000#;
            U2 := (U2 and 2#0011_1111#) * 2#010_000_0000_0000#;
            U3 := (U3 and 2#0011_1111#) * 2#0100_0000#;
            U4 := U4 and 2#0011_1111#;

            Item :=
              VSS.Characters.Virtual_Character'Val (U1 or U2 or U3 or U4);
            Self.Current := Self.Current + 4;

         when others =>
            Report_Error
              ("invalid UTF-8 sequence (wrong start code unit)");
      end case;
   end Get;

   ---------------
   -- Has_Error --
   ---------------

   overriding function Has_Error
     (Self : Memory_UTF8_Input_Stream) return Boolean is
   begin
      return not Self.Diagnosis.Is_Null;
   end Has_Error;

   --------------------
   -- Is_End_Of_Data --
   --------------------

   overriding function Is_End_Of_Data
     (Self : Memory_UTF8_Input_Stream) return Boolean is
   begin
      if Self.Current > Self.Buffer.Length then
         return False;
      end if;

      return True;
   end Is_End_Of_Data;

   ----------------------
   -- Is_End_Of_Stream --
   ----------------------

   overriding function Is_End_Of_Stream
     (Self : Memory_UTF8_Input_Stream) return Boolean is
   begin
      return Self.Current > Self.Buffer.Length;
   end Is_End_Of_Stream;

   ---------
   -- Put --
   ---------

   overriding procedure Put
     (Self    : in out Memory_UTF8_Output_Stream;
      Item    : VSS.Characters.Virtual_Character;
      Success : in out Boolean)
   is
      pragma Unreferenced (Success);

      use type VSS.Implementation.UTF8_Encoding.UTF8_Sequence_Length;

      Code : constant VSS.Unicode.Code_Point :=
        VSS.Characters.Virtual_Character'Pos (Item);
      L    : VSS.Implementation.UTF8_Encoding.UTF8_Sequence_Length;
      U1   : VSS.Unicode.UTF8_Code_Unit;
      U2   : VSS.Unicode.UTF8_Code_Unit;
      U3   : VSS.Unicode.UTF8_Code_Unit;
      U4   : VSS.Unicode.UTF8_Code_Unit;

   begin
      VSS.Implementation.UTF8_Encoding.Encode (Code, L, U1, U2, U3, U4);

      Self.Buffer.Append (Ada.Streams.Stream_Element (U1));

      if L >= 2 then
         Self.Buffer.Append (Ada.Streams.Stream_Element (U2));

         if L >= 3 then
            Self.Buffer.Append (Ada.Streams.Stream_Element (U3));

            if L = 4 then
               Self.Buffer.Append (Ada.Streams.Stream_Element (U4));
            end if;
         end if;
      end if;
   end Put;

end VSS.Text_Streams.Memory;
