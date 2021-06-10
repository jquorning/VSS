--
--  Copyright (C) 2020-2022, AdaCore
--
--  SPDX-License-Identifier: Apache-2.0
--

--  Conversion between standard string types and Magic_String.

with Ada.Strings.Unbounded;
with Ada.Strings.UTF_Encoding;
with Ada.Strings.Wide_Wide_Unbounded;

package VSS.Strings.Conversions is

   pragma Preelaborate;

   function To_Virtual_String
     (Item : Ada.Strings.UTF_Encoding.UTF_8_String) return Virtual_String;

   function To_Virtual_String
     (Item : Ada.Strings.Unbounded.Unbounded_String) return Virtual_String;
   --  Convert UTF-8 encoded unbounded string into Virtual_String.

   function To_Virtual_String
     (Item : Ada.Strings.Wide_Wide_Unbounded.Unbounded_Wide_Wide_String)
      return Virtual_String;
   --  Convert UCS-4 encoded unbounded string into Virtual_String.

   function To_UTF_8_String
     (Item : Virtual_String'Class)
      return Ada.Strings.UTF_Encoding.UTF_8_String;
   --  Convert virtual string into UTF-8 encoded string.

   function To_Unbounded_UTF_8_String
     (Item : Virtual_String'Class)
      return Ada.Strings.Unbounded.Unbounded_String;
   --  Convert virtual string into UTF-8 encoded unbounded string.

   function To_Wide_Wide_String
     (Item : Virtual_String'Class) return Wide_Wide_String;
   --  Convert virtual string into Wide_Wide_String.

   function To_Unbounded_Wide_Wide_String
     (Item : Virtual_String'Class)
      return Ada.Strings.Wide_Wide_Unbounded.Unbounded_Wide_Wide_String;
   --  Convert virtual string into Wide_Wide_String.

   procedure Set_UTF_8_String
     (Item : Virtual_String'Class;
      Into : out Ada.Strings.UTF_Encoding.UTF_8_String);
   --  Set given Into string to content of virtual string. Length of the Into
   --  string must be equal to the length in code units of the content of the
   --  virtual string encoded in UTF-8; otherwise Constraint_Error is raised.

   procedure Set_UTF_8_String
     (Item : Virtual_String'Class;
      Last : out Natural;
      Into : out Ada.Strings.UTF_Encoding.UTF_8_String);
   --  Fill given Into string by content of virtual string. Data is written
   --  starting from the first character. Remaining length of the string
   --  must be at least the length in code units of the content of the
   --  virtual string encoded in UTF-8; otherwise Constraint_Error is raised.

   procedure Set_UTF_8_String
     (Item : Virtual_String'Class;
      From : Positive;
      Last : out Natural;
      Into : out Ada.Strings.UTF_Encoding.UTF_8_String);
   --  Fill given Into string by content of virtual string. Data is written
   --  starting From character. Remaining length of the string must be at
   --  least the length in code units of the content of the virtual string
   --  encoded in UTF-8; otherwise Constraint_Error is raised.

   procedure Set_Wide_Wide_String
     (Item : Virtual_String'Class;
      Into : out Wide_Wide_String);
   --  Set given Into string to content of virtual string. Length of the
   --  string must be equal to the length in characters of the virtual
   --  string; otherwise Constraint_Error is raised.

   procedure Set_Wide_Wide_String
     (Item : Virtual_String'Class;
      Last : out Natural;
      Into : out Wide_Wide_String);
   --  Fill given Into string by content of virtual string. Data is written
   --  starting from first character. Length of the string must be at
   --  least the length in characters of the virtual string; otherwise
   --  Constraint_Error is raised.

   procedure Set_Wide_Wide_String
     (Item : Virtual_String'Class;
      From : Positive;
      Last : out Natural;
      Into : out Wide_Wide_String);
   --  Fill given Into string by content of virtual string. Data is written
   --  starting From character. Remaining length of the string must be
   --  at least the length in characters of the virtual string; otherwise
   --  Constraint_Error is raised.

end VSS.Strings.Conversions;
