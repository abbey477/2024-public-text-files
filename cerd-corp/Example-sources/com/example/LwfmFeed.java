
package com.example;

import java.util.List;
import javax.annotation.Generated;

@Generated("jsonschema2pojo")
public class LwfmFeed {

    public String feedDomain;
    public String uniqueId;
    public String componentName;
    public String fileLoadedStatus;
    public int recordsReceived;
    public int recordsRejected;
    public int recordsLoaded;
    public String comment;
    public String batchId;
    public List<CustomAttribute> customAttributes;
    public List<TargetInfo> targetInfo;
    public String businessDate;
    public String arrivedTime;
    public String loadedTime;

}
