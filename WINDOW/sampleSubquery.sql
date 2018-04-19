/*
Write the code to determine the most-common dormroom type for students 
who have special needs of either 'Physical Access' or 
'Preparation Accommodation' who completed a business school course 
before 1989 with a grade between 3.4 and 3.8
*/
use UNIVERSITY
go
select * from tblDORMROOM_TYPE DT
join tblDORMROOM D 
	on D.DormRoomTypeID = DT.DormRoomTypeID
join tblSTUDENT_DORMROOM SD 
	on SD.DormRoomID = D.DormRoomID
join (
		select STU.StudentID
		from tblSTUDENT STU
		join tblSTUDENT_SPECIAL_NEED SSN
			on STU.StudentID = SSN.StudentID
		join tblSPECIAL_NEED SPN
			on SPN.SpecialNeedID = SSN.SpecialNeedID
		where SPN.SpecialNeedName LIKE '%Physical Access%' 
			OR SPN.SpecialNeedName like '%Preparation Accommodation%'
		) ST
	on ST.StudentID = SD.StudentID
join (
		select StudentID, ClassID
		from tblCLASS_LIST CL
		where CL.Grade between 3.4 and 3.8
		) CLL
	on CLL.StudentID = ST.StudentID
join (
		select ClassID, CourseID
		from tblCLASS CLASS 
		where CLASS.YEAR < 1989
		) C
	on C.ClassID = CLL.ClassID
join tblCOURSE CO
	on CO.CourseID = C.CourseID
join tblDEPARTMENT DPT
	on DPT.DeptID = CO.DeptID
join (
		select CollegeID 
		from tblCOLLEGE COLL
		where COLL.CollegeName like '%Business%'
		) COL
	on COL.CollegeID = DPT.CollegeID