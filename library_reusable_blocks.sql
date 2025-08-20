
-- Use the library database
USE librarydb;

-- ============================================
-- 1. Stored Procedure: GetBorrowingsByMemberName
-- ============================================
-- Parameters:
--   p_membername VARCHAR - Member name
-- Logic:
--   If the member has borrowings, return their borrowed books.
--   Otherwise, return a message saying "No borrowings found".
DELIMITER $$

CREATE PROCEDURE GetBorrowingsByMemberName(IN p_membername VARCHAR(100))
BEGIN
    DECLARE v_memberid INT;

    -- Get member ID from name
    SELECT memberid INTO v_memberid
    FROM members
    WHERE membername = p_membername
    LIMIT 1;

    -- Check if member exists and has borrowings
    IF v_memberid IS NOT NULL AND 
       EXISTS (SELECT 1 FROM borrowings WHERE memberid = v_memberid) THEN
        SELECT m.membername, b.title, br.borrowdate, br.returndate
        FROM borrowings br
        JOIN books b ON br.bookid = b.bookid
        JOIN members m ON br.memberid = m.memberid
        WHERE br.memberid = v_memberid;
    ELSE
        SELECT CONCAT('No borrowings found for Member: ', p_membername) AS message;
    END IF;
END$$

DELIMITER ;

-- Example usage:
-- CALL GetBorrowingsByMemberName('Alice Smith');

-- ============================================
-- 2. Stored Procedure: AddNewMember
-- ============================================
-- Parameters:
--   p_membername VARCHAR - Member name
--   p_joindate DATE - Date of joining
-- Logic:
--   If the member does not exist, insert them.
--   Otherwise, return a message saying the member already exists.
DELIMITER $$

CREATE PROCEDURE AddNewMember(IN p_membername VARCHAR(100), IN p_joindate DATE)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM members WHERE membername = p_membername) THEN
        INSERT INTO members (membername, joindate) VALUES (p_membername, p_joindate);
        SELECT CONCAT('New member "', p_membername, '" added successfully.') AS message;
    ELSE
        SELECT CONCAT('Member "', p_membername, '" already exists.') AS message;
    END IF;
END$$

DELIMITER ;

-- Example usage:
-- CALL AddNewMember('Charlie Brown', '2025-08-14');

-- ============================================
-- 3. Function: GetAuthorBookCountByName
-- ============================================
-- Parameters:
--   p_authorname VARCHAR - Author name
-- Returns:
--   Total number of books written by the author.
DELIMITER $$

CREATE FUNCTION GetAuthorBookCountByName(p_authorname VARCHAR(100))
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE total_books INT;
    DECLARE v_authorid INT;

    -- Get author ID from name
    SELECT authorid INTO v_authorid
    FROM authors
    WHERE name = p_authorname
    LIMIT 1;

    -- Count books by author
    SELECT COUNT(*) INTO total_books
    FROM books
    WHERE authorid = v_authorid;

    RETURN total_books;
END$$

DELIMITER ;

-- Example usage:
-- SELECT GetAuthorBookCountByName('George Orwell') AS total_books;
