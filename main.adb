with Ada.Text_IO; use Ada.Text_IO;
with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;
with Ada.Real_Time; use Ada.Real_Time;
with Ada.Containers.Indefinite_Vectors;

procedure Main is
   Number_Of_Threads : Integer;
   Wait_Time : Integer;
   Progression_Delta : Integer;

   protected Stop_Flag is
      procedure Set;
      function Get return Boolean;
   private
      can_stop : Boolean := False;
   end Stop_Flag;

   protected body Stop_Flag is
      procedure Set is
      begin
         can_stop := True;
      end Set;

      function Get return Boolean is
      begin
         return can_stop;
      end Get;
   end Stop_Flag;

   procedure Validate_Input (Message : String; Value : out Integer) is
      Valid : Boolean := False;
   begin
      loop
         Put(Message);
         Get(Value);
         if Value >= 1 and Value <= 30 then
            Valid := True;
            exit;
         else
            Put_Line("Invalid input. Please enter a value between 1 and 30.");
         end if;
      end loop;
   end Validate_Input;

   task type Break_Thread is
      entry Start(Delay_Time : Integer);
   end Break_Thread;

   task body Break_Thread is
      Time_Duration : Duration;
   begin
      accept Start(Delay_Time : Integer) do
         Time_Duration := Duration(Delay_Time);
      end Start;
      delay Time_Duration;
      Stop_Flag.Set;
   end Break_Thread;

   task type Main_Thread (Progression_Delta : Long_Long_Integer; Id : Integer);

   task body Main_Thread is
      Sum : Long_Long_Integer := 0;
   begin
      loop
         Sum := Sum + Progression_Delta;
         exit when Stop_Flag.Get;
      end loop;
      Put_Line("Runner" & Id'Image & " finished with sum: " & Long_Long_Integer'Image(Sum));
   end Main_Thread;

   type Main_Thread_Access is access Main_Thread;
   package Thread_Vector is new Ada.Containers.Indefinite_Vectors
     (Index_Type   => Natural,
      Element_Type => Main_Thread_Access);

   Thread_List : Thread_Vector.Vector;

   B1 : Break_Thread;
begin
   Put_Line("Lab 1, made by Oleksiienko Pavlo");
   Put_Line("Threads are calculating the arithmetical progression with a given delta.");
   Put_Line("");
   Validate_Input("Please enter number of threads (1-30):", Number_Of_Threads);
   Put_Line("");
   Validate_Input("Please enter wait time in seconds (1-30):", Wait_Time);
   Put_Line("");
   Validate_Input("Please enter integer progression delta (1-30):", Progression_Delta);
   Put_Line("");

   B1.Start(Wait_Time);

   for I in 1 .. Number_Of_Threads loop
      Thread_List.Append(new Main_Thread(Long_Long_Integer(Progression_Delta), I));
   end loop;
   null;
end Main;
