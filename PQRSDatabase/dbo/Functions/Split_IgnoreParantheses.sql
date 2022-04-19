


CREATE FUNCTION [dbo].[Split_IgnoreParantheses] (
      @InputString                  VARCHAR(8000),
      @Delimiter                    VARCHAR(50)
)

RETURNS @Items TABLE (
      Item  VARCHAR(8000)
)

AS
BEGIN
      IF @Delimiter = ' '
      BEGIN
            SET @Delimiter = ','
            SET @InputString = REPLACE(@InputString, ' ', @Delimiter)
      END

      IF (@Delimiter IS NULL OR @Delimiter = '')
            SET @Delimiter = ','



      DECLARE @Item           VARCHAR(8000)
      DECLARE @ItemList       VARCHAR(8000)
      DECLARE @DelimIndex     INT
      DECLARE @BraceStartIndex	  INT
      DECLARE @BraceEndIndex	  INT
      declare @LastBrace int

      SET @ItemList = @InputString
      SET @DelimIndex = CHARINDEX(@Delimiter, @ItemList, 0)
      
     
      WHILE (@DelimIndex != 0)
      BEGIN
            SET @BraceStartIndex = CHARINDEX('(',@ItemList,0)
            if ((@BraceStartIndex != 0) and (@BraceStartIndex < @DelimIndex))
            Begin
				 SET @BraceEndIndex = CHARINDEX(')',@ItemList,0)
					if ((@BraceEndIndex != 0 ) and (@BraceEndIndex > @DelimIndex) and (@BraceEndIndex <LEN(@ItemList) ) )
					Begin
						set @DelimIndex = @BraceEndIndex + 1;
						set @LastBrace= 0;
					End
					else if ((@BraceEndIndex != 0 ) and (@BraceEndIndex > @DelimIndex) and (@BraceEndIndex = LEN(@ItemList) ) )
					Begin
						set @DelimIndex = @BraceEndIndex;
						set @LastBrace = 1
					End
            
					SET @Item = SUBSTRING(@ItemList, 0, @DelimIndex + @LastBrace )
            End
            else 
            Begin
				SET @Item = SUBSTRING(@ItemList, 0, @DelimIndex)
            End
            
            
            INSERT INTO @Items VALUES (@Item)

            -- Set @ItemList = @ItemList minus one less item
            SET @ItemList = SUBSTRING(@ItemList, @DelimIndex+1, LEN(@ItemList)-@DelimIndex)
            SET @DelimIndex = CHARINDEX(@Delimiter, @ItemList, 0)
      END -- End WHILE

      IF @Item IS NOT NULL -- At least one delimiter was encountered in @InputString
      BEGIN
            SET @Item = @ItemList 
            if ltrim(rtrim(ISNULL(@Item,''))) <> ''
            Begin
				INSERT INTO @Items VALUES (@Item)
            End
      END

      -- No delimiters were encountered in @InputString, so just return @InputString
      ELSE INSERT INTO @Items VALUES (@InputString)

      RETURN

END -- End Function



