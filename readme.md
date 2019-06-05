<h2>This directory has files needed to build scripts to run the datastage jobs.</h2>

<p>The files here are really to build a shell script (and it's supporting properties) needed to run datastage jobs.
I did this cause I needed to perform the task repeatedly and doing it thru the user interface was taking
a while (and wasting my time watching a screen).  I have it were you can process one group of jobs or you can<
use the 'makeAllJobs.sh' to create an exec that will run them all.</p>
<p>Read the scripts if you need more detail, should make sense.</p>
<p>Also, this is just a quick and dirty utility I wrote; can definitely improve a lot, but see how often
you use it first :)</p>

<hr />
<p>It's easier to explain how this works with an example so things will make sense as you read thru this,
be patient, might be confusing at first.</p>

<p>For the most part; there are two custom files for each job stream; they use other files but
most of the others are shared across jobs.</p>

<p>I'll use the 'Assets' job stream as an example.<br/>
First file: 'asset_vars.py' this contains the variable definitions; this is imported at runtime (will 
  make more sense later).  If you look at this file you'll see:

<dl>
  <dt>jobs2Run</dt>
    <dd>an array of the jobs to run for this stream (most have only one but some (like sap) have
        multiple jobs listed</dd>
  <dt>stubFiles</dt>
    <dd>these are the stub 'parameter' files used for the job; most have the 'global_stub.properties'
        and 'db_stub.properties' since they're common in many jobs.  The other one is usually 
        unique to this job</dd>
  <dt>script2Create</dt>
    <dd>this is the name of the shell script that will be created (most vars file has
        this as 'runDataStageJobs.sh').  Also note: there are property files that are
        created, they have the name &lt;jobs2Run&gt;_program.properties</dd>
</dl>


<p>Second file: this is the 'unique stub properties file', for assets it's called: 'asset_stub.properties'
    the code reads the 'stub' files and creates an associated properties file for when the job is run.</p>

<h3>General notes</h3>
<ul>
  <li>You don't want to 'pollute' the directory where projects are run from, so I put all the files
      in a subdirectory off it, I used './runDSJobs'; you put everything in there and run the actual
      script to trigger the job from there also</li>
  <li>The default project is mine (sandbox-media3); if you want to change it you can use<pre>
      sed -i 's/sandbox-media3/projectName/g' *_vars.py</pre>
      (I'd do this in a copy of the files in case things go wrong).</li>
  <li>The pw's for the connections are in the 'stub' files</li>
  <li>The repository used is in the '*_vars.py' files</li>
  <li>You may want to make 'stub'/'var' files for different connections/repo's, but I just used 'sed' to 
      make versions I wanted</li>
  <li>You don't want to have pw's in the files up in a public repo (git) so I created exec 'changePw.py', 
      run it like './changePw.py all set' to set the pw or './changePw.py all clear' to clear the pw.
      You can also run it for one file ('i.e. ./changePw.py asset set'), look at code for the names of
      the respective keys to use.<br/>
      <strong>Note:</strong> I didn't put the changePw.py file here but take a look at changePw.sample,
      it's the code without the actual pw's... change the 'realPw' value to be the pw for the
      associated data source</li>
</ul>

<h3>Test drive</h3>
<ul>
  <li>Pretend you want to create the shell/properties file so you can run 'sj_Assets' job; you'd do:<pre>
     ./makeJob.sh asset_vars</pre>
      Note you don't suffix the file with .py
      When you execute this it'll create 'runDataStageJobs.sh' and 'sj_Assets_program.properties', if you
      want to run this job stream then just do './runDataStageJobs.sh'</li>
  <li>Pretend you want to change the project (to live) for the assets job, you might do:<pre>
      cp asset_vars.py asset_vars.py_backup # Make backup
      sed -i 's/sandbox-media3/live/g' asset_vars.py # Change inplace</pre></li>
  <li>Pretend you want to create a script to run (almost) all the jobs, in the scheduled order, then run<pre>
      './makeAllJobs.sh'</pre>
      this will create a 'runDatastageJobs.sh', run (runDatastageJobs.sh), and be patient... takes hours 
      to complete</li>
  <li>If you want to support a new job stream (say the weekly bluepages pull) you'd do
    <ul>
      <li>Need to create the stub (properties) file for it
          <ul>
            <li>Open director (or designer), I used production server</li>
            <li>Go to the job log for 'sj_Organization_Weekly'</li>
            <li>Double click on the 'Starting Job sj_Organization_Weekly....' line to see the parameters used</li>
            <li>You DON'T want the lines associated with 'Global..' (that's already in global_stub.properties file) or
                'BCRSIW...' values (they're in db_stub.properties). <br/>The one's you want are the lines for 'BMSIW...',
                select those lines and copy into file 'organization_weekly_stub.properties'.  Note: you don't need the
                line BMSIW_Connection_Parms = (As pre-defined), you only need the ones that are in the
                form BMSIW_Connection_Parms.&lt;parmName&gt;</li>
            <li>After you paste the lines remove the '(text)' after the value assignment, they're just comments and
                shouldn't be in the stub file</li>
          </ul>
      </li>
      <li>Create the 'organization_weekly_vars.py' file (variables for import)
        <ul>
          <li>I'd copy an existing file (i.e. cp views.vars.py organization_weekly_vars.py)</li>
          <li>Edit organization_weekly_vars.py
             <ul>
                <li>Change jobs2Run to ["sj_Organizanization_Weekly"]</li>
                <li>Change stubFiles so that it has ["organization_weekly_stub.properties","global_stub.properties","db_stub.properties"]</li>
                <li>The other values should be fine as is... but change if you want to use a different repo etc...</li>
             </ul>
          </li>
        </ul>
      </li>
      <li>Test it out... run 'makeJob.sh organization_weekly_vars', then run the resulting shell (runDatastageJobs.sh)</li>
    </ul>
  </li>
</ul>      

<h3>Future</h3>
<ul>
  <li>I was going to code the 'makeJob.sh' shell so that it will run the job too, put in parm but didn't
      code it... it want it should be trivial to add</li>
</ul>
  