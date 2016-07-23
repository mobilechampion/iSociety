// Amazon Web Services
//#define TOKEN_VENDING_MACHINE_URL    @"anonymousdimetvm-env.elasticbeanstalk.com"
#define TOKEN_VENDING_MACHINE_URL    @"anonymousthedimetvm-env.elasticbeanstalk.com"
#define USE_SSL                      NO
#define CREDENTIALS_ALERT_MESSAGE    @"Please update the Constants.h file with the Token Vending Machine URL."

// AWS S3 constants
#define ACCESS_KEY_ID          @""
#define S3TRANSFERMANAGER_BUCKET @"s3-transfer-manager-bucket"
//#define S3BUCKET_NAME @"thedime.dimevideos"
#define S3BUCKET_NAME @"thedime.admedia"
#define S3REGION US_WEST_1
#define CLOUDFRONT_URL @"http://d3sf8khx0m9dmv.cloudfront.net/%@"

// Check out this url for a list of regions: http://docs.aws.amazon.com/general/latest/gr/rande.html
#define DYNAMODB_REGION             (AmazonRegion) US_WEST_1

#define CATEGORY_TABLE              @"Category"
#define CATEGORY_KEY                @"categoryId"
#define CATEGORY_VERSIONS           @"version"

#define ADS_TABLE                @"Ads"
#define ADS_KEY                  @"adId"
#define ADS_VERSIONS             @"version"

#define SUBCATEGORY_TABLE           @"SubCategory"
#define SUBCATEGORY_KEY             @"subCategoryId"
#define SUBCATEGORY_VERSIONS        @"version"

#define NEW_CHECKIN                  -99

// Video Capture
#define VIDEO_LENGTH_NORMAL     20
#define VIDEO_LENGTH_FREE_AD    30
#define VIDEO_LENGTH_PAID_AD    60

// Ad Expiration
#define EXPIRATION_DAYS_FREE_AD 14
#define EXPIRATION_DAYS_PAID_AD 30

// Messages
#define UPLOAD_FAILED_TITLE NSLocalizedString( @"Upload NOT successful!", nil)
#define UPLOAD_FAILED_MESSAGE NSLocalizedString(@"Your ad upload was not successful! Do you want to retry?", nil)
#define UPLOAD_SUCCESSFUL_TITLE NSLocalizedString(@"Upload Successful!", nil)
#define UPLOAD_SUCCESSFUL_MESSAGE NSLocalizedString(@"Your ad was uploaded successfully!", nil)

