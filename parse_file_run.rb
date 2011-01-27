# This program written by Jeffrey McLurkin and Richard Phares on 11-13-2010
# is for the use of the Los Angeles County Sheriff's Department (LASD) 
# Santa Clarita Valley Station.  All rights reserved by the LASD with support by
# Jeffrey McLurkin and Richard Phares.  Additional use by permission only.
# Jeffrey  McLurkin reserves the right to use code segments for other programs
# but will not distribute the whole code without LASD permission.
# Jeffrey McLurkin will provide six months support at no additional charge,
# starting 01-01-2011.  He can be reached at
# Jeffrey McLurkin (jeffrey.mclurkin@gmail.com).
# line 242 is set to run through year 2013.  It will need adjusting after that.
#

# last modification 01-19-2011
# last modification 01-25-2011 added retry for the copy_file
# 01-26-11 fix directory for SVB
# and new comments in regular expressions

$LOAD_PATH << File.dirname(__FILE__)

require "FileUtils"
require 'logger'

class ParseFile
  # this section is the variables housing which location the files will be
  # moved to.
  # You can define any location you wish.
  #
  # @a = "C:/TEST/URN_FILES"
  # @a = "//1-sct/share files/PUBLIC SCAN/URN Files"
  @a = "//1-sct-01/URNFiles"
  # @b = "C:/TEST/DB_LT"
  @b = "//1-sct-01/DB_Inbox/DB_LT"
  # @c = "C:/TEST/CA_INBOX"
  @c = "//1-sct-01/DB_Inbox/DB_CrimeAnalyst"
  # @d = "C:/TEST/DB_INBOX"
  @d = "//1-sct-01/DB_Inbox/DB_Other"
  # @e = "C:/TEST/PATROL_DEPUTY"
  @e = "//1-sct-01/DB_Inbox/DB_Patrol_Deputy"
  # @f = "C:/TEST/TRAFFIC"
  @f = "//1-sct/share files/Traffic Files/Inbox_Traffic"
  # @g = "C:/TEST/ARSON_EXPLOSIVE"
  @g = "//1-eoc/!_aed_incoming_reports_!"
  # @h = "C:/TEST/TRAP"
  @h = "//1-sct/share files/public scan/Urn Files/Manual_Dist"
  # @i = "C:/TEST/CCB"
  @i = "//1-stars-ccb01/Paperless/Incoming_Reports"
  # @j = "C:/TEST/SVB"
  @j = "//1-stars/sharefil/Incoming/SCT_SVB_Incoming_Reports"
  # @k = "C:/TEST/HOMOCIDE"
  @k = "//1-Hom/!_Homicide_Incoming_Reports_!"
  # @l = "C:/TEST/NARCO"
  @l = "//1-sct-01/DB_Inbox/Narco"
  # @m = "C:/TEST/CAT_MCAD"
  @m = "//1-sct/share files/public scan/Urn Files/Manual_Dist"
  # @n = "C:/TEST/MAJORS"
  @n = "//1-sct/share files/public scan/Urn Files/Manual_Dist"
  # @o = "C:/TEST/RIB"
  @o = "//1-sct/share files/public scan/Urn Files/Manual_Dist"
  # @p = "C:/TEST/INDUST_RELAT"
  @p = "//1-sct/share files/public scan/Urn Files/Manual_Dist"
  # @q = "C:/TEST/MANUAL_DIST"
  @q = "//1-sct/share files/public scan/Urn Files/Manual_Dist"
  # @r = "C:/TEST/DB_INBOX/ACTIVE"
  @r = "//1-sct-01/DB_Inbox/DB_Active"
  # @s = "C:/TEST/DB_INBOX/INCUSTODY"
  @s = "//1-sct-01/DB_Inbox/DB_Incustody"
  # @t = "C:/TEST/DB_INBOX/PENDING"
  @t = "//1-sct-01/DB_Inbox/DB_Pending"
  # @z = "C:/TEST/OTHER"
  # @z = "//1-sct/share files/public scan/Urn Files/Manual_Dist"

  # this "@@conf defines the code number to the correct name for the file
  # i.e. 1= "49A, 2="49IC" etc.
  @@conf = {'1'    => "49A",
            '2'    => "49IC",
            '3'    => "49P",
            '4'    => "49I",
            '5'    => "DUI",
            '6'    => "TC",
            '7'    => "MP",
            '8'    => "MPS",
            '9'    => "S180",
            '10'   => "R180",
            '11'   => "L180",
            '12'   => "P180",
            '13'   => "AO180",
            '14'   => "PHO",
            '15'   => "SOF",
            '16'   => "SUP",
            '17'   => "REPO",
            '18'   => "VESL",
            '19'   => "VESR",
            '20'   => "VESAO",
            '21'   => "HAZM",
            '22'   => "LDC",
            '23'   => "MI",
            '24'   => "OM",
            '25'   => "VAI",
            '26'   => "VOID",
            '27'   => "BK",
            '28'   => "BK1",
            '29'   => "ERO",
            '30'   => "AI",
            '31'   => "FR"}

  # this section @@sort and @@sort2, is the process that moves the above
  # locations into place for each file movement.  i.e. the "A" code letter on
  # the original scanned file states that the report
  # should be filed in the four  locations below i.e. @a, @b, @c, @e.
  @@sort = {'A' => [@a, @b, @c, @e],
            'B' => [@a, @b, @c, @d],
            'C' => [@a, @f],
            'D' => [@g, @a, @b, @c],
            'E' => [@a, @b, @c, @h],
            'F' => [@i, @a, @b, @c],
            'G' => [@j, @a, @b, @c],
            'H' => [@a, @b, @c, @k],
            'I' => [@a, @b, @c, @l],
            'J' => [@a, @b, @c, @m],
            'K' => [@a, @b, @c, @n],
            'L' => [@a, @b, @c, @o],
            'M' => [@a, @b, @c, @p],
            'N' => [@a, @e, @l],
            'O' => [@a, @d],
            'P' => [@a, @b],
            'Q' => [@a, @s],
            'X' => [@a],
            'Z' => [@q]}
  
@@sort1 =  {'A' => [@a, @b, @c, @e],
            'B' => [@a, @b, @c, @r],
            'C' => [@a, @f],
            'D' => [@g, @a, @b, @c],
            'E' => [@a, @b, @c, @h],
            'F' => [@i, @a, @b, @c],
            'G' => [@j, @a, @b, @c],
            'H' => [@a, @b, @c, @k],
            'I' => [@a, @b, @c, @l],
            'J' => [@a, @b, @c, @m],
            'K' => [@a, @b, @c, @n],
            'L' => [@a, @b, @c, @o],
            'M' => [@a, @b, @c, @p],
            'N' => [@a, @e, @l],
            'O' => [@a, @d],
            'P' => [@a, @b],
            'Q' => [@a, @s],
            'X' => [@a],
            'Z' => [@q]}
  
@@sort2 =  {'A' => [@a, @b, @c, @e],
            'B' => [@a, @b, @c, @s],
            'C' => [@a, @f],
            'D' => [@g, @a, @b, @c],
            'E' => [@a, @b, @c, @h],
            'F' => [@i, @a, @b, @c],
            'G' => [@j, @a, @b, @c],
            'H' => [@a, @b, @c, @k],
            'I' => [@a, @b, @c, @l],
            'J' => [@a, @b, @c, @m],
            'K' => [@a, @b, @c, @n],
            'L' => [@a, @b, @c, @o],
            'M' => [@a, @b, @c, @p],
            'N' => [@a, @e, @l],
            'O' => [@a, @d],
            'P' => [@a, @b],
            'Q' => [@a, @s],
            'X' => [@a],
            'Z' => [@q]}
              
@@sort3 =  {'A' => [@a, @b, @c, @e],
            'B' => [@a, @b, @c, @t],
            'C' => [@a, @f],
            'D' => [@g, @a, @b, @c],
            'E' => [@a, @b, @c, @h],
            'F' => [@i, @a, @b, @c],
            'G' => [@j, @a, @b, @c],
            'H' => [@a, @b, @c, @k],
            'I' => [@a, @b, @c, @l],
            'J' => [@a, @b, @c, @m],
            'K' => [@a, @b, @c, @n],
            'L' => [@a, @b, @c, @o],
            'M' => [@a, @b, @c, @p],
            'N' => [@a, @e, @l],
            'O' => [@a, @d],
            'P' => [@a, @b],
            'Q' => [@a, @s],
            'X' => [@a],
            'Z' => [@q]}
  
  def initialize(dir)
    @count = 0
    @basedir = dir
    FileUtils.cd(@basedir)
    @log = Logger.new('logfile.log', 'weekly')
    @out = Logger.new(STDOUT)
    @log.level = Logger::INFO
    @out.level = Logger::INFO
    @log.datetime_format = "%Y-%m-%d %H:%M:%S"
    @out.datetime_format = "%Y-%m-%d %H:%M:%S"        
  end

  def start
    @log.info("Program started")
    @out.info("Program started")
    read_files
    @log.info("Total of #{@count} files routed")
    @out.info("Total of #{@count} files routed")
    @log.info("Program success")
    @out.info("program success")
    @log.close
    @out.close
  end

  # get a list of filenames in the directory to be renamed
  def read_files
    contains = Dir.new(@basedir).entries
    @log.info("**** #{contains.count().to_s} files in directory #{@basedir} *****")
    @out.info("**** #{contains.count().to_s} files in directory #{@basedir} *****")
    # Process each file in the list
    begin
      contains.each do |name|
        if verify_file_name(name)
         @count += 1
          @old_name = name
          process_file
        end
      end
    rescue => err
        @log.fatal("Caught exception; exiting")
        @log.fatal(err)
        @out.fatal("Caught exception; exiting")
        @out.fatal(err)
    end
  end

  def verify_file_name(name)
    #  YEAR     DIR   STATION CODE  LOCATION
    #   $1      $2      $3     $4      $5
    # (\d{2})-(\d{5})-(\d{2})-(\d+)([A-Q,XZ])
    reg = /^(\d{2})-(\d{5})-(\d{2})-(\d+)([A-Q,XZ])/

    if reg.match(name)
      dir = $2
    else
      @log.error "invalid file name #{name}"
      @out.error "invalid file name #{name}"
      return false
    end

    if $1.to_i > 6 && $1.to_i < 14
      year = $1
    else
      @log.error("invalid file #{name}, year #{$1} is not a valid year")
      @out.error("invalid file #{name}, year #{$1} is not a valid year")
      return false
    end

    if $3.to_i > 0 && $3.to_i < 27 || $3.to_i == 83
      station = $3
    else
      @log.error("invalid file #{name}, station #{$3} is not valid")
      @out.error("invalid file #{name}, station #{$3} is not valid")
      return false
    end

    if $4.to_i > 0 && $4.to_i < 32
      code = @@conf[$4]
    else
      @log.error("invalid file #{name}, code #{$4} is out of range")
      @out.error("invalid file #{name}, code #{$4} is out of range")
      return false
    end

    if '1' == $4
      @dist = @@sort1[$5]
    elsif '2' == $4
      @dist = @@sort2[$5]
    elsif '3' == $4
      @dist = @@sort3[$5]
    else
      @dist = @@sort[$5]
    end

    @dir = "#{year}-#{dir}"
    @name = "#{year}-#{dir}-#{station}-#{code}.pdf"
	  @urn_dir = "URN 20#{year}/#{@dir}"
  end

  def process_file
    distribute_file_to_each_location
    # You can comment this line out if you do not want to delete the files
    # when testing.
    remove_file
  end

  def distribute_file_to_each_location
    if @dist == nil
    else
      @dist.each do |x|  # x is the location directory from @a - @z 
                         #(ex. @a = "//1-sct-01/URNFiles")
        if x == nil
          @log.error("The location of directory is missing")
          @out.error("The location of directory is missing")
        else
          set_new_location(x)
          copy_file_to_new_location
        end
      end
    end
  end

  def set_new_location(to_dir) 
    # to_dir is the location directory from @a - @z
    #(ex. @a = "//1-sct-01/URNFiles")
    reg = /URNFiles/
    if reg.match(to_dir)
       @new_location = "#{to_dir}/#{@urn_dir}"
    else
       @new_location = "#{to_dir}"
    end
  end

  def copy_file_to_new_location
    # verify if the to_dir exists if it doesn't add it
    verify_directory
    name = "#{@new_location}/#{@name}"
    base = name.chomp(".pdf")
    suffix = 0  # Initialize the suffix to 0.
    # Check to see if file exists if it does add suffix until its
    # unique name then copy the file
    while File.exists? name
      suffix = suffix + 1
      # You can change the suffix from - to . here
      name = "#{base}-#{suffix}.pdf"
    end
    copy_file(name)
  end

  # verify if the to_dir exists if it doesn't add it
  def verify_directory
     FileUtils.makedirs @new_location
  end

  def copy_file(name)
    tries = 0
    if @dist == nil
    else
      begin
	  # Copy file to new location if there's a conflict the rescue is executed
        FileUtils.cp @old_name, name
		    @log.info("old name #{@old_name} new name #{name}")
        @out.info("old name #{@old_name} new name #{name}")
		# Try to do copy 5 times after waiting 10 seconds if not
    # successful write an error in the log file
      rescue
        tries += 1
        sleep 10
        retry if tries <= 5
        @log.error("Failed to copy file old name = #{@old_name} new name = #{name}!")
        @out.error("Failed to copy file old name = #{@old_name} new name = #{name}!")
      end
    end
  end

  def remove_file
    tries = 0
    if @dist == nil
    else
      begin
	  # Delete old file from source directory if there's a conflict
    # the rescue is executed 5 times
        FileUtils.rm @old_name
		@log.info("Delete #{@old_name} success")
        @out.info("Delete #{@old_name} success")
		# Try to delete file 5 times after waiting 10 seconds if not successful
    # write an error in the log file
      rescue
        tries +=1
        sleep 10
        retry if tries <= 5
        @log.error("Failed to remove file #{@old_name} from #{@basedir}!")
        @out.error("Failed to remove file #{@old_name} from #{@basedir}!")
      end
    end
  end
end

# creates the object to do our work for us. The object name is a.
# a = ParseFile.new("C:/test") # The directory that has the files
# to be distributed.
# a.start # Start the process.

# creates the object to do our work for us. The object name is a.
#a = ParseFile.new("C:/test") # The source directory that has the files
# to be distributed.
a = ParseFile.new("//1-sct/share files/PUBLIC SCAN/URN processing folder")
a.start # Start the process.