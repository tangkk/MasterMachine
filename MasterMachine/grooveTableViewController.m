//
//  grooveTableViewController.m
//  WIJAM-MASTER
//
//  Created by Michelle Wong SU on 4/28/13.
//  Copyright (c) 2013 Michelle Wong SU. All rights reserved.
//

#import "grooveTableViewController.h"
/*
static NSString* documents[] =
{   
    @"drum44.mp3",
    @"drum68.mp3",
    @"Ballad3inGLydian.mp3",
    @"Ballad4inFIonian.mp3",
    @"drumshuffle.mp3"
};
*/
#define NUM_DOCS 5

@interface grooveTableViewController ()

@property (nonatomic, strong) DirectoryWatcher *docWatcher;
@property (nonatomic, strong) NSMutableArray *documentURLs;
@property (nonatomic, strong) UIDocumentInteractionController *docInteractionController;

@end

@implementation grooveTableViewController
//@synthesize grooveArray;

- (void)setupDocumentControllerWithURL:(NSURL *)url
{
    if (self.docInteractionController == nil)
    {
        self.docInteractionController = [UIDocumentInteractionController interactionControllerWithURL:url];
        self.docInteractionController.delegate = self;
    }
    else
    {
        self.docInteractionController.URL = url;
    }
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {        
        // Custom initialization
        self.docWatcher = [DirectoryWatcher watchFolderWithPath:[self applicationDocumentsDirectory] delegate:self];
        
        self.documentURLs = [NSMutableArray array];
        
        // scan for existing documents
        [self directoryDidChange:self.docWatcher];

    }
    return self;
}

//-(void)passArray:(NSMutableArray *)grooveNameArray{
//    grooveArray = grooveNameArray;
//}

- (void)viewDidLoad

{
    [super viewDidLoad];

    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    // start monitoring the document directory…
        
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
//#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//#warning Incomplete method implementation.
   // Return the number of rows in the section.
    //return NUM_DOCS;
    return self.documentURLs.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    NSURL *fileURL;
    //fileURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:documents[indexPath.row] ofType:nil]];
    fileURL = [self.documentURLs objectAtIndex:indexPath.row];
    // Configure the cell...
    cell.textLabel.text = [[[fileURL path] lastPathComponent] stringByDeletingPathExtension];
    cell.textLabel.font = [UIFont fontWithName:@"Noteworthy-Bold" size:18.0];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.backgroundColor =[UIColor clearColor];
    cell.backgroundColor = [UIColor blackColor];
    
    NSString *fileURLString = [self.docInteractionController.URL path];
    NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:fileURLString error:nil];
    NSInteger fileSize = [[fileAttributes objectForKey:NSFileSize] intValue];
    NSString *fileSizeStr = [NSByteCountFormatter stringFromByteCount:fileSize
                                                           countStyle:NSByteCountFormatterCountStyleFile];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ - %@", fileSizeStr, self.docInteractionController.UTI];
    
    [tableView setSeparatorColor:[UIColor whiteColor]];
    tableView.backgroundColor = [UIColor blackColor];
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
    
    // Get the URL
    NSURL *grooveURL;
    grooveURL = [self.documentURLs objectAtIndex:indexPath.row];
    NSString *FileName = [[[grooveURL path] lastPathComponent] stringByDeletingPathExtension];
   // [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    //Notify the delegate if it exists.
    if (_delegate != nil) {
        [_delegate selectedgroove:grooveURL withName:FileName];
    }
}

#pragma mark - File system support

- (NSString *)applicationDocumentsDirectory
{
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

- (void)directoryDidChange:(DirectoryWatcher *)folderWatcher
{
	[self.documentURLs removeAllObjects];    // clear out the old docs and start over
	
	NSString *documentsDirectoryPath = [self applicationDocumentsDirectory];
	
	NSArray *documentsDirectoryContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsDirectoryPath error:NULL];
    
	for (NSString* curFileName in [documentsDirectoryContents objectEnumerator])
	{
        //NSLog(@"'%@'", [curFileName pathExtension]);
        if ([[curFileName pathExtension] isEqualToString:@"mp3"]) {
            NSString *filePath = [documentsDirectoryPath stringByAppendingPathComponent:curFileName];
            NSURL *fileURL = [NSURL fileURLWithPath:filePath];
            
            BOOL isDirectory;
            [[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDirectory];
            
            if (!(isDirectory ))
            {
                [self.documentURLs addObject:fileURL];
            }
        }
	}
	
	[self.tableView reloadData];
}


@end
