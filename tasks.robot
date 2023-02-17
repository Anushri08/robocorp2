*** Settings ***
Documentation       Orders robots from RobotSpareBin Industries Inc.
...                 Saves the order HTML receipt as a PDF file.
...                 Saves the screenshot of the ordered robot.
...                 Embeds the screenshot of the robot to the PDF receipt.
...                 Creates ZIP archive of the receipts and the images.
Library             RPA.Browser.Selenium    auto_close=${FALSE}
Library             RPA.HTTP
Library             RPA.Excel.Files
Library    RPA.Tables
Library    RPA.PDF
Library    RPA.Archive
Library    RPA.FileSystem

*** Tasks ***
Orders robots from RobotSpareBin Industries Inc.
    Open the Intranet website
    ${orders}=    Get orders
    FOR    ${row}    IN    @{orders}
        Close the annoying modal
        Fill the form    ${row}
        Wait Until Keyword Succeeds    10X    5sec    Preview the robot
        Wait Until Keyword Succeeds    10X    5sec    Submit the order
        ${pdf}=    Store the receipt as a PDF file    ${row}[Order number]
        ${screenshot}=    Take a screenshot of the robot    ${row}[Order number]
        Embed the robot screenshot to the receipt PDF file    ${screenshot}    ${pdf}
        Order new robot
        # Create new receipt PDF with robot image    ${row}[Order number]    ${screenshot}
        
    END
    Create zip file
    


*** Keywords ***
Open the Intranet website
    Open Available Browser    https://robotsparebinindustries.com/#/robot-order    maximized=${True}

Close the annoying modal
    Wait And Click Button    xpath://*[@id="root"]/div/div[2]/div/div/div/div/div/button[1]
    # Set Local Variable    ${btn_new}    xpath://*[@id="root"]/div/div[2]/div/div/div/div/div/button[1]
    # Wait Until Element Is Visible     ${btn_new}
    # Click Button     ${btn_new}

    
    
    

# Read and enter data from csv file
#     Open Workbook    orders.csv
#     ${order_nos}=   Read Worksheet As Table    orders.csv    header=True
#     # Close Workbook
#     FOR    ${order_no}    IN    @{order_nos}
#         Fill and submit the form for one person    ${order_no}
        
#     END



Get orders
    Download    https://robotsparebinindustries.com/orders.csv    overwrite=True
    ${order_records}=    Read table from CSV    orders.csv    header=True
    RETURN    ${order_records}
    
Fill the form 
    [Arguments]    ${row}
    Select From List By Index    head    ${row}[Head]
    Select Radio Button    body    ${row}[Body]
    Input Text    xpath:/html/body/div/div/div[1]/div/div[1]/form/div[3]/input    ${row}[Legs]
    Input Text    address    ${row}[Address]
    

Preview the robot
    Click Button    preview
    Wait Until Element Is Visible    preview

Submit the order
    Click Button    order
    Page Should Contain Element    xpath://*[@id="receipt"]
    

# Store the receipt as a PDF file
#     [Arguments]    ${orderdata}
#     Wait Until Element Is Visible    id:receipt
#     ${receipt_html}=    Get Element Attribute    id:receipt    outerHTML
#     Html To Pdf    ${receipt_html}    ${OUTPUT_DIR}${/}receipt.pdf

Store the receipt as a PDF file
    [Arguments]    ${orderdata}
    ${receipt_html} =    Get Element Attribute    xpath://*[@id="receipt"]    outerHTML
    Html To Pdf    ${receipt_html}    ${OUTPUT_DIR}${/}pdf/receipt_${orderdata}.pdf
    [Return]    ${OUTPUT_DIR}${/}pdf/receipt_${orderdata}.pdf
    

Take a screenshot of the robot
    [Arguments]    ${orderdata}
    Screenshot    robot-preview-image    ${OUTPUT_DIR}${/}screenshot/screenshot_${orderdata}.png
    [Return]    ${OUTPUT_DIR}${/}screenshot/screenshot_${orderdata}.png



Embed the robot screenshot to the receipt PDF file
    [Arguments]    ${screenshot}    ${pdf}
    Open Pdf    ${pdf}
    ${image} =    Create List    ${screenshot}:align=center
    Add Files To PDF    ${image}    ${pdf}    append=True
    # Close Pdf    ${pdf}


Create new receipt PDF with robot image
    [Arguments]    ${order_number}    ${screenshot}
    ${pdf} =    Store the receipt as a PDF file    ${order_number}
    Embed the robot screenshot to the receipt PDF file    ${screenshot}    ${pdf}


 Order new robot
     Click Button   xpath://*[@id="order-another"]


Create zip file    
    ${zip_file}=    Set Variable    ${OUTPUT_DIR}/PDFs.zip
    Archive Folder With Zip
    ...    ${OUTPUT_DIR}
    ...    ${zip_file}
    
