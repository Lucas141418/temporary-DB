USE [NOVA_DEV_DB]
--Creacion de tablas
CREATE TABLE Roles(
	role_id INTEGER PRIMARY KEY NOT NULL IDENTITY(1,1),
	role_type VARCHAR(255),
);
GO
CREATE TABLE Schedules(
	schedule_id INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
	Start_Date DATE,
	end_date DATE,
);
GO

CREATE TABLE Users (
    user_id INT IDENTITY(1,1) NOT NULL,
    id VARCHAR(MAX) NOT NULL,
    name VARCHAR(MAX) NOT NULL,
    lastname VARCHAR(MAX) NOT NULL,
    phone INT NULL,
    email VARCHAR(MAX) NOT NULL,
    gender CHAR(1) NOT NULL,
    date_of_birth DATETIME NOT NULL,
    profile_picture VARBINARY(MAX) NULL,
    schedule_id INT NULL,
    medical_record_id INT NULL,
    location_map GEOGRAPHY NULL,
    age VARCHAR(50) NULL,
    status INT NULL,
	CONSTRAINT FK_Users_schedules FOREIGN KEY(schedule_id) REFERENCES Schedules(schedule_id),
    CONSTRAINT [PK_USERS] PRIMARY KEY CLUSTERED ([user_id] ASC)
        WITH (
            PAD_INDEX = OFF,
            STATISTICS_NORECOMPUTE = OFF,
            IGNORE_DUP_KEY = OFF,
            ALLOW_ROW_LOCKS = ON,
            ALLOW_PAGE_LOCKS = ON
        ) ON [PRIMARY]
) ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY];

CREATE TABLE Medical_Records(
	medical_record_id INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
	medical_prescription VARCHAR(MAX),
	exam_results VARCHAR(MAX),
	family_history VARCHAR (MAX),
	patient_id INT,
	CONSTRAINT FK_MEDICAL_RECORDS_PATIENT FOREIGN KEY (patient_id) REFERENCES Users(user_id)
);
GO
ALTER TABLE Users 
	ADD CONSTRAINT FK_Users_Medical_records_id FOREIGN KEY (medical_record_id) REFERENCES Medical_Records(medical_record_id)


ALTER TABLE Medical_Records
	ADD CONSTRAINT FK_Medical_records_Users FOREIGN KEY (patient_id) REFERENCES Users(user_id)


CREATE TABLE User_roles(
	user_id INT,
    role_id INT,
    FOREIGN KEY (user_id) REFERENCES Users(user_id),
    FOREIGN KEY (role_id) REFERENCES Roles(role_id)
)

CREATE TABLE Locations(
	location_id INTEGER PRIMARY KEY NOT NULL IDENTITY(1,1),
	name VARCHAR(25) NOT NULL,
	parent_id INTEGER NULL
	CONSTRAINT FK_PARENT_LOCATION FOREIGN KEY (parent_id)
    REFERENCES Locations(location_id)
)


CREATE TABLE Headquarters(
    hq_id int PRIMARY KEY IDENTITY(1,1) NOT NULL,
    name varchar(50) not null,
    description varchar(255) not null,
    date_incorporation date,
    picture VARCHAR(MAX),
    other_sings varchar(255),
    location_map Geography,
    location_id INT,
	active INT NOT NULL DEFAULT 1,
	CONSTRAINT FK_HEADQUARTERS_LOCATION_ID FOREIGN KEY (location_id) REFERENCES Locations(location_id)
);

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE User_headquarters(
    user_id int NOT NULL,
	hq_id int NOT NULL,
    CONSTRAINT PK_USER_HEADQUARTERS PRIMARY KEY CLUSTERED 
    (
        user_id ASC,
        hq_id ASC
    ),
    CONSTRAINT FK_USER_HEADQUARTERS_USERS FOREIGN KEY (user_id) REFERENCES Users(user_id),
    CONSTRAINT FK_USER_HEADQUARTERS_HEADQUARTERS FOREIGN KEY (hq_id) REFERENCES Headquarters(hq_id)
);
GO
CREATE TABLE Specialties(
	specialty_id int PRIMARY KEY IDENTITY(1,1) NOT NULL,
	specialty_name VARCHAR(255),
	description VARCHAR(255)
);
GO
CREATE TABLE User_specialties(
    user_id int NOT NULL,
    specialty_id int NOT NULL,
    CONSTRAINT PK_USER_SPECIALTIES PRIMARY KEY CLUSTERED 
    (
        [user_id] ASC,
        [specialty_id] ASC
    ),
    CONSTRAINT [FK_USER_SPECIALTIES_USERS] FOREIGN KEY ([user_id]) REFERENCES Users([user_id]),
    CONSTRAINT [FK_USER_SPECIALTIES_SPECIALTIES] FOREIGN KEY ([specialty_id]) REFERENCES Specialties([specialty_id])
);
GO
CREATE TABLE Passwords(
	password_id int IDENTITY(1,1) NOT NULL,
    user_id INT NOT NULL,
    password VARBINARY (MAX) NOT NULL,
	registration_time DATETIME2 DEFAULT GETDATE(),
    CONSTRAINT PK_PASSWORDS PRIMARY KEY CLUSTERED (password_id),
    CONSTRAINT FK_PASSWORDS_USERS FOREIGN KEY (user_id) REFERENCES Users(user_id)
);
GO

ALTER TABLE Passwords

CREATE TABLE Otps (
    user_id INT NOT NULL,
    expiration_time DATETIME NOT NULL,
    CONSTRAINT PK_OTPS PRIMARY KEY CLUSTERED (user_id),
    CONSTRAINT FK_OTPS_USERS FOREIGN KEY (user_id) REFERENCES Users(user_id)
);
GO
CREATE TABLE Reservation_slots(
	reservation_slot_id INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
	star_time Date,
	end_time Date,
	availability_status CHAR(1),
	professional_id INT,
	hq_id INT,
	CONSTRAINT FK_APPOINTMENTS_PROFESSIONAL FOREIGN KEY (professional_id) REFERENCES Users(user_id),
	CONSTRAINT FK_APPOINTMENTS_HEADQUARTERS FOREIGN KEY (hq_id) REFERENCES Headquarters(hq_id)
);
go
CREATE TABLE Booked_slots(
    booked_slot_id INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
	booked_ts DATETIME,
    user_id INT,
    reservation_slot_id INT,
    CONSTRAINT FK_BOOKED_SLOTS_USERS FOREIGN KEY (user_id) REFERENCES Users(user_id),
    CONSTRAINT FK_BOOKED_SLOTS_RESERVATION_SLOTS FOREIGN KEY (reservation_slot_id) REFERENCES Reservation_slots(reservation_slot_id)
);
GO
CREATE TABLE Appointments(
    appointment_id INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
    date_created TIMESTAMP,
    notes VARCHAR(MAX),
    nursing_notes VARCHAR(MAX),
    status VARCHAR(50),
    diagnosis VARCHAR(MAX),
    hq_id INT,
    specialty_id INT,
    patient_id INT,
    professional_id INT,
    reservation_slot_id INT,
    CONSTRAINT FK_APPO_HQ FOREIGN KEY (hq_id) REFERENCES Headquarters(hq_id),
    CONSTRAINT FK_APPO_SPECIALTIES FOREIGN KEY (specialty_id) REFERENCES Specialties(specialty_id),
    CONSTRAINT FK_APPO_PATIENT FOREIGN KEY (patient_id) REFERENCES Users(user_id),
    CONSTRAINT FK_APPO_PRO FOREIGN KEY (professional_id) REFERENCES Users(user_id),
    CONSTRAINT FK_APPO_RESERVATION_SLOT FOREIGN KEY (reservation_slot_id) REFERENCES Reservation_slots(reservation_slot_id)
);
GO

CREATE TABLE Prescriptions(
	prescription_id INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
	recommended_dose VARCHAR(255),
	duration VARCHAR(255),
	picture VARBINARY,
	notes VARCHAR(MAX),
	medications VARCHAR(MAX),
	dosage VARCHAR(255),
	issuance_date DATETIME,
	appointment_id INT,
	CONSTRAINT FK_PRESCRIPTIONS_APPOINTMENTS FOREIGN KEY (appointment_id) REFERENCES Appointments(appointment_id)
);
GO

CREATE TABLE Payment_information(
	payment_id INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
	price INT,
	appointment_id INT,
	CONSTRAINT FK_PAYMENT_INFORMATION_APPOINTMENTS FOREIGN KEY (appointment_id) REFERENCES Appointments(appointment_id)
);
GO

CREATE TABLE Exams(
	exam_id INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
	examen_type VARCHAR(25),
	result VARCHAR(255),
	patient_id INT,
	CONSTRAINT FK_EXAMS_PATIENT FOREIGN KEY (patient_id) REFERENCES Users(user_id)
);
GO
CREATE TABLE Exam_users (
    exam_id INT,
    user_id INT,
    CONSTRAINT PK_EXAM_USER PRIMARY KEY CLUSTERED (exam_id, user_id),
    CONSTRAINT FK_EXAM_USER_EXAMS FOREIGN KEY (exam_id) REFERENCES Exams(exam_id),
    CONSTRAINT FK_EXAM_USER_USERS FOREIGN KEY (user_id) REFERENCES Users(user_id)
);
GO


--Vistas
CREATE VIEW VW_PROVINCIA_CANTON_DISTRITO
as
	SELECT 
		D.location_id as id,
		D.name AS district_name,
		C.name AS canton_name,
		P.name AS province_name
	FROM 
		Locations AS D
	JOIN 
		Locations AS C ON D.parent_id = C.location_id
	JOIN 
		Locations AS P ON C.parent_id = P.location_id;


--SP GET ALL
CREATE PROCEDURE SP_GENERAL_QUERY_GET_ALL
@table_name VARCHAR (50)
AS
DECLARE @query VARCHAR(MAX)
SET @query = 'SELECT * FROM '+@table_name
EXECUTE (@query)


--SP CREATE PROFESSIONALS
CREATE PROCEDURE SP_CREATE_PROFESSIONAL
	@id VARCHAR(MAX),
    @name VARCHAR(MAX),
    @lastname VARCHAR(MAX) ,
    @phone INT,
    @email VARCHAR(MAX) ,
    @gender CHAR(1),
    @date_of_birth DATETIME ,
    @profile_picture VARBINARY(MAX),
    @schedule_id INT,
    @location_map GEOGRAPHY,
    @age VARCHAR(50),
    @status INT
AS
	DECLARE @temp_id INT 
	SET NOCOUNT ON;
	BEGIN TRY
	BEGIN TRANSACTION
	INSERT INTO [dbo].[Users]
	(	id,
		name,
		lastname,
		phone,
		email,
		gender,
		date_of_birth,
		profile_picture,
		schedule_id,
		medical_record_id,
		location_map,
		age,
		status
		)
	VALUES(
		@id,
		@name ,
		@lastname ,
		@phone ,
		@email  ,
		@gender,
		@date_of_birth  ,
		@profile_picture,
		@schedule_id,
		null,
		@location_map,
		@age,
		@status)
	SET @Temp_id = SCOPE_IDENTITY()
	INSERT INTO User_roles(user_id,role_id) VALUES(@temp_id,2)
	COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
		print('No se realizo el SP desde SQL, error: ' +   ERROR_MESSAGE())
            ROLLBACK TRANSACTION
    END CATCH


--SP Examenes 
--CREATE EXAM
CREATE PROCEDURE SP_CREATE_EXAM_FOR_PACIENT
    @examen_type VARCHAR(25),
    @result VARCHAR(255),
	@patient_id INT
AS
	DECLARE @temp_id INT
	BEGIN
		SET NOCOUNT ON
		BEGIN TRY
        BEGIN TRANSACTION

			INSERT INTO Exams
			(
				examen_type,
				result,
				patient_id
			)
			VALUES(
				@examen_type,
				@result,
				@patient_id
			)

			SET @temp_id = SCOPE_IDENTITY()
			INSERT INTO Exam_users (exam_id, user_id) VALUES(@temp_id, @patient_id)
			COMMIT TRANSACTION;
		END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
        BEGIN
            DECLARE @Error_message VARCHAR(MAX);
            DECLARE @Error_status INT;
            SET @Error_message = ERROR_MESSAGE();
            SET @Error_status = ERROR_STATE();
            ROLLBACK TRANSACTION;
            THROW @Error_status, 'Error updating exam SQL: ',  @Error_message;
        END;
    END CATCH;
END;
--SP FOR UPDATING EXAMS
CREATE PROCEDURE SP_UPDATE_EXAMS_BY_EXAM_ID
    @exam_id int,
    @examen_type VARCHAR(25),
    @result VARCHAR(255)
AS
	BEGIN
		SET NOCOUNT ON;
		BEGIN TRY
        BEGIN TRANSACTION;
        
			UPDATE Exams
				SET
					examen_type = @examen_type,
					result = @result
				WHERE exam_id = @exam_id;
			COMMIT TRANSACTION;
		END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
        BEGIN
            DECLARE @Error_message VARCHAR(MAX);
            DECLARE @Error_status INT;
            SET @Error_message = ERROR_MESSAGE();
            SET @Error_status = ERROR_STATE();
            ROLLBACK TRANSACTION;
            THROW @Error_status, 'Error updating exam SQL: ',  @Error_message;
        END;
    END CATCH;
END;
--SP GET EXAMS 
CREATE PROCEDURE SP_GET_EXAMS_BY_PATIENT_ID
    @patient_id INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        SELECT E.examen_type, E.result, E.patient_id,E.exam_id
               U.id, U.date_of_birth, U.email, U.name, U.lastname, U.phone 
        FROM Exams E
        INNER JOIN Exam_users EU ON E.exam_id = EU.exam_id
        INNER JOIN Users U ON EU.user_id = U.user_id
        WHERE U.user_id = @patient_id;
    END TRY
    BEGIN CATCH
        DECLARE @Error_message VARCHAR(MAX);
        DECLARE @Error_status INT;
        SET @Error_message = ERROR_MESSAGE();
        SET @Error_status = ERROR_STATE();
        THROW @Error_status, 'Error retrieving exams for patient: ', @Error_message;
    END CATCH;
END;
--SP MEdical RECORD

CREATE PROCEDURE SP_CREATE_MEDICAL_RECORD
	@medical_prescription VARCHAR(MAX),
	@exam_results VARCHAR(MAX),
	@family_history VARCHAR (MAX),
	@patient_id INT
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		BEGIN TRANSACTION;

		DECLARE @temp_id INT;

		INSERT INTO Medical_Records
		(
			medical_prescription,
			exam_results,
			family_history,
			patient_id
		)
		VALUES (
			@medical_prescription,
			@exam_results,
			@family_history,
			@patient_id
		);

			SET @temp_id = SCOPE_IDENTITY()
			UPDATE Users SET medical_record_id = @temp_id WHERE user_id = @patient_id
			COMMIT TRANSACTION;
		END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
        BEGIN
            DECLARE @Error_message VARCHAR(MAX);
            DECLARE @Error_status INT;
            SET @Error_message = ERROR_MESSAGE();
            SET @Error_status = ERROR_STATE();
            ROLLBACK TRANSACTION;
            THROW @Error_status, 'Error updating exam SQL: ',  @Error_message;
        END;
    END CATCH;
END;

--GET MD by Patient
CREATE PROCEDURE SP_GET_MEDICAL_RECORD_BY_PatientId
    @patient_id INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        SELECT ME.medical_prescription, ME.exam_results, ME.family_history,
               U.id, U.date_of_birth, U.email, U.name, U.lastname, U.phone 
        FROM Medical_Records ME
        INNER JOIN Users U ON ME.patient_id = U.user_id
        WHERE U.user_id = @patient_id;
    END TRY
    BEGIN CATCH
        DECLARE @Error_message VARCHAR(MAX);
        DECLARE @Error_status INT;
        SET @Error_message = ERROR_MESSAGE();
        SET @Error_status = ERROR_STATE();
        THROW @Error_status, 'Error retrieving MEDICAL RECORD for patient: ', @Error_message;
    END CATCH;
END;
--UPDATE Medical Record
CREATE PROCEDURE SP_UPDATE_MEDICAL_RECORD
	@medical_record_id int,
	@medical_prescription VARCHAR(MAX),
	@exam_results VARCHAR(MAX),
	@family_history VARCHAR (MAX)
AS
	BEGIN
		SET NOCOUNT ON;
		BEGIN TRY
        BEGIN TRANSACTION;
        
			UPDATE Medical_Records
				SET
					medical_prescription = @medical_prescription,
					exam_results = @exam_results,
					family_history = @family_history
				WHERE medical_record_id = @medical_record_id;
			COMMIT TRANSACTION;
		END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
        BEGIN
            DECLARE @Error_message VARCHAR(MAX);
            DECLARE @Error_status INT;
            SET @Error_message = ERROR_MESSAGE();
            SET @Error_status = ERROR_STATE();
            ROLLBACK TRANSACTION;
            THROW @Error_status, 'Error updating medicalRecord SQL: ',  @Error_message;
        END;
    END CATCH;
END
--SP GET ALL HQ
CREATE PROCEDURE SP_HEADQUARTERS_GET_ALL_ACTIVE
AS
BEGIN
    SELECT * FROM Headquarters WHERE active = 1; 
END

--SP INSERT HQ
CREATE PROCEDURE [dbo].[SP_HEADQUARTERS_INSERT]
    @name VARCHAR(50),
    @description VARCHAR(255),
    @date_incorporation DATE,
    @picture VARCHAR(MAX),
    @other_sings VARCHAR(255),
    @location_map VARCHAR(MAX),
    @location_id INT,
    @active INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO Headquarters (name, description, date_incorporation, picture, other_sings, location_map, location_id, active)
        VALUES (@name, @description, @date_incorporation, @picture, @other_sings, geography::STGeomFromText('POINT('+@location_map+')', 4326), @location_id, @active);

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
        BEGIN
            ROLLBACK TRANSACTION;
        END;
        THROW;
    END CATCH;
END;
--SP DELETE HQ
CREATE PROCEDURE SP_HEADQUARTERS_DELETE
    @hq_id INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE Headquarters
        SET active = 0 -- Marcar como inactivo en lugar de eliminar físicamente
        WHERE hq_id = @hq_id;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
        BEGIN
            ROLLBACK TRANSACTION;
        END;
        THROW;
    END CATCH;
END
--SP GET ID HQ
CREATE PROCEDURE SP_HEADQUARTERS_GET_BY_ID
    @hq_id INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        SELECT * FROM Headquarters WHERE hq_id = @hq_id;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH;
END
--SP UPDATE HQ
/** Object:  StoredProcedure [dbo].[SP_HEADQUARTERS_UPDATE]    Script Date: 3/23/2024 10:42:02 AM **/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_HEADQUARTERS_UPDATE]
    @hq_id INT,
    @name VARCHAR(50),
    @description VARCHAR(255),
    @date_incorporation DATE,
    @picture VARCHAR(MAX),
    @other_sings VARCHAR(255),
    @location_map VARCHAR(MAX),
    @location_id INT,
    @active INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE Headquarters
        SET name = @name, description = @description, date_incorporation = @date_incorporation,
            picture = @picture, other_sings = @other_sings, location_map = geography::STGeomFromText('POINT('+@location_map+')', 4326),
            location_id = @location_id, active = @active
        WHERE hq_id = @hq_id;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
        BEGIN
            ROLLBACK TRANSACTION;
        END;
        THROW;
    END CATCH;
END
--INSERT INTO EJEMPLO
INSERT INTO Headquarters (name, description, date_incorporation, picture, other_sings, location_map, location_id)
VALUES ('Nombre de la Sede', 'Descripción de la Sede', '2024-03-23', 'ruta/de/la/imagen.jpg', 'Otras señales', 'POINT(-74.0059 40.7128)', 1);


--SP LogIN
--Function to search the last password
CREATE FUNCTION F_GET_THE_LAST_PASSWORD(@P_user_id INT) RETURNS VARCHAR(MAX)
AS
BEGIN
    DECLARE @LAST_PASSWORD VARCHAR(MAX);

    SELECT TOP 1 @LAST_PASSWORD = password
    FROM Passwords
    WHERE user_id = @P_user_id
    ORDER BY registration_time DESC; 

    RETURN @LAST_PASSWORD;
END;

CREATE PROCEDURE SP_VERIFY_USER
    @Email VARCHAR(MAX),
    @Password VARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @UserId INT
    DECLARE @last_Password VARCHAR(MAX)
    DECLARE @LoginSuccess BIT
    DECLARE @UserName VARCHAR(MAX)
	DECLARE @UserLastName VARCHAR(MAX)
	DECLARE @UserRole VARCHAR(255)
	DECLARE @UserEmail VARCHAR(MAX)
    BEGIN TRY
        BEGIN TRANSACTION;
        SELECT @UserId = U.user_id FROM Users U
        WHERE U.email = @Email;

        IF @UserId IS NOT NULL
        BEGIN
            SET @last_Password = dbo.F_GET_THE_LAST_PASSWORD(@UserId);
            IF @last_Password = @Password
            BEGIN
                SET @LoginSuccess = 1;
                SELECT @UserName = U.name, @UserLastName = U.lastname, @UserEmail = U.email FROM Users U
                WHERE U.user_id = @UserId;
				SELECT @UserRole = R.role_type FROM User_roles UR INNER JOIN Roles R ON UR.user_id = @UserId WHERE R.role_id = UR.role_id
            END
            ELSE
            BEGIN
                SET @LoginSuccess = 0;
            END
        END
        ELSE
        BEGIN
            SET @LoginSuccess = 0;
        END;
        IF @@TRANCOUNT > 0
            COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        SELECT ERROR_MESSAGE() AS ErrorMessage;
    END CATCH;
    SELECT @LoginSuccess AS LoginSuccess, @UserName AS UserName, @UserLastName AS UserLastName, @UserEmail AS UserEmail, @UserRole AS UserRole;
END;




select *  from Passwords
use NOVA_TEST_LOCAL
EXEC SP_VERIFY_USER 'janesmith@example.com', 'passwordTestLast24'